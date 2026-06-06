#!/usr/bin/env bash
##
##  backup-system.sh
##
##  Aggressively mirror a hard-coded list of system paths into a single
##  destination directory using rclone (local -> local).
##
##    sudo ./backup-system.sh /path/to/backup/destination
##
##  - The destination directory is the only CLI argument and is `mkdir -p`-ed.
##  - Each source is mirrored into "<destination><source>" so that several
##    sources never clobber one another in the same destination root
##    (e.g. /home  ->  <destination>/home).
##  - `rclone sync` makes it a true mirror: files that no longer exist in the
##    source are DELETED at the destination.
##  - Symlinks are preserved AS symlinks and never followed (rclone --links).
##  - The rclone flags reproduce the "aggressive" profile of fxMirrorSsh()
##    (bash-fx/scripts/file-transfer.sh), minus the SSH/sftp-specific options
##    and the webapp-specific filters.
##  - The destination MUST live on a separate mounted disk, not the root
##    filesystem: if the backup disk is unmounted/disconnected its mount point
##    reverts to a plain dir on "/" and rclone would silently fill the system
##    disk. We refuse to run in that case (see assertDestinationOnSeparateDisk).
##

source "/usr/local/turbolab.it/webstackup/script/base.sh"

printHeader "💾 SYSTEM BACKUP"
rootCheck

## ============================================================================
## Configuration
## ============================================================================

## Hard-coded list of paths to back up. Extend as needed.
## NOTE: do NOT add pseudo-filesystems (/proc, /sys, /dev, /run) and do NOT add
##       a path that contains the backup destination, or rclone will refuse to
##       run (overlapping paths). If you ever add a path that spans other mount
##       points, consider adding --one-file-system to RCLONE_FLAGS below.
SOURCE_PATHS=(
  "/home"
  "/root"
  "/etc"
  "/var/www"
  "/usr/local/turbolab.it"
  "/usr/local/bin"
)

## Patterns excluded from the backup (rclone --exclude), matched at ANY depth.
## NB: use "name/**" (NOT "**/name/**") for directories. A leading "**/" makes
## rclone skip the match when the dir sits at a source root (e.g. /root/.cache),
## so it would silently leak into the backup; "name/**" matches root AND nested.
## --delete-excluded (below) also strips these from the destination on re-runs.
## Comment a line out to keep that data.
RCLONE_EXCLUDES=(
  ## Log files (any depth)
  "*.log"

  ## Regenerable caches & trash (safe: nothing lost, no extra restore step)
  ".cache/**"
  ".npm/**"
  ".local/share/Trash/**"

  ## Dependency & build dirs (regenerable, but a restore then needs a reinstall
  ## of that project: npm/pnpm/yarn install, composer install, etc.)
  "node_modules/**"
  "vendor/**"
  ".venv/**"
  "__pycache__/**"
  ".next/**"
  ".nuxt/**"
  ".svelte-kit/**"
  "target/**"
  ".gradle/**"

  ## snapd auto-generates systemd units (snap-*.mount per snap revision, plus
  ## snap.<name>.service/.timer and wants-symlinks); all are recreated on snap
  ## install/refresh, so they are never worth restoring (and their long names
  ## trip up SMB/CIFS destinations with "invalid argument").
  ## NB: patterns are relative to each source root, so for /etc this is
  ## "systemd/system/...", not "etc/systemd/system/...".
  "systemd/system/snap*"
  "systemd/system/snap*/**"
  ## ...and the enable-symlinks snapd plants in *.target.wants/ subdirs
  "systemd/system/**/snap*"
  ## same story for the per-user units snapd generates
  "systemd/user/snap*"
  "systemd/user/snap*/**"
  "systemd/user/**/snap*"
  ## ...and the udev rules it generates (keep the rest of udev/rules.d:
  ## that's where hand-written rules live)
  "udev/rules.d/70-snap.*"

  ## Broader names that sometimes hold real data — enable only if yours don't:
  #"build/**"
  #"dist/**"
  #"out/**"
  #"venv/**"
  ## Rotated logs (*.log.1, *.log.2.gz, ...) if you also want them gone:
  #"*.log.*"
)

## Lock: refuse to start a second, concurrent backup.
## Life is in minutes; an older lockfile is considered stale and ignored.
LOCK_NAME="backup-system"
LOCK_TIMEOUT_MIN=1440

## ============================================================================
## Helpers
## ============================================================================

## Write a manifest of installed software into the destination so the machine
## can be rebuilt quickly. Stored under <destination>/system-manifest, a path no
## source sync touches, so the mirror never deletes it. Best-effort: a missing
## tool or a failed command just skips that file.
function dumpSystemManifest()
{
  local MANIFEST_DIR="${BACKUP_DESTINATION}/system-manifest"
  printTitle "📦 Saving system manifest..."

  if ! mkdir -p "${MANIFEST_DIR}"; then
    printLightWarning "⚠️  Could not create '${MANIFEST_DIR}': skipping the manifest"
    return
  fi

  [ -n "$(command -v dpkg)" ]     && dpkg --get-selections     > "${MANIFEST_DIR}/packages-dpkg.txt"       2>/dev/null
  [ -n "$(command -v apt-mark)" ] && apt-mark showmanual       > "${MANIFEST_DIR}/packages-apt-manual.txt" 2>/dev/null
  [ -n "$(command -v snap)" ]     && snap list                 > "${MANIFEST_DIR}/packages-snap.txt"       2>/dev/null
  [ -n "$(command -v flatpak)" ]  && flatpak list              > "${MANIFEST_DIR}/packages-flatpak.txt"    2>/dev/null
  [ -n "$(command -v pip3)" ]     && pip3 list --format=freeze > "${MANIFEST_DIR}/packages-pip3.txt"       2>/dev/null

  {
    echo "Generated: $(date)"
    echo "Host:      $(hostname)"
    echo "Kernel:    $(uname -a)"
    [ -n "$(command -v lsb_release)" ] && lsb_release -a 2>/dev/null
  } > "${MANIFEST_DIR}/system-info.txt" 2>/dev/null

  fxOK "System manifest written to ${MANIFEST_DIR}"
}

## Refuse to run unless the destination sits on a mounted disk that is NOT the
## root filesystem. Rationale: the destination is meant to be an external /
## secondary disk. If that disk is unmounted (or disconnects mid-run), its mount
## point becomes an ordinary directory on "/" and rclone happily fills the
## system disk with the backup. We compare the filesystem device id of the
## destination against "/"'s: same device => the backup disk is not mounted.
function assertDestinationOnSeparateDisk()
{
  local TARGET="$1"
  printTitle "🔌 Checking the destination is on a mounted disk..."

  ## The destination usually does not exist yet (we mkdir -p it later), so test
  ## its nearest EXISTING ancestor. This walk always terminates at "/".
  local PROBE="${TARGET}"
  while [ ! -e "${PROBE}" ]; do
    PROBE="$(dirname "${PROBE}")"
  done

  local TARGET_DEV ROOT_DEV
  TARGET_DEV="$(stat -c '%d' "${PROBE}" 2>/dev/null)"
  ROOT_DEV="$(stat -c '%d' "/"       2>/dev/null)"

  if [ -z "${TARGET_DEV}" ] || [ -z "${ROOT_DEV}" ]; then
    catastrophicError "Could not stat '${PROBE}' or '/' to verify the destination disk"
  fi

  if [ "${TARGET_DEV}" = "${ROOT_DEV}" ]; then
    catastrophicError "Destination '${TARGET}' is on the ROOT filesystem, not a separate mounted disk. Is the backup disk disconnected/unmounted? Mount it first. Refusing to run so we don't fill the system disk."
  fi

  fxOK "Destination is on a mounted disk separate from / (device ${TARGET_DEV})"
}

## ============================================================================
## Input validation
## ============================================================================

BACKUP_DESTINATION="$1"

if [ -z "${BACKUP_DESTINATION}" ]; then
  catastrophicError "No destination directory given. Usage: sudo $0 /path/to/backup/destination"
fi

## We run as root: never trust a relative path here.
if [ "${BACKUP_DESTINATION:0:1}" != "/" ]; then
  catastrophicError "The destination must be an ABSOLUTE path (got '${BACKUP_DESTINATION}')"
fi

## Normalize (strip trailing slash) and guard against the root filesystem.
BACKUP_DESTINATION="${BACKUP_DESTINATION%/}"

if [ -z "${BACKUP_DESTINATION}" ] || [ "${BACKUP_DESTINATION}" = "/" ]; then
  catastrophicError "Refusing to use '/' as the backup destination"
fi

## Refuse a destination that lives inside one of the sources (overlap = the
## backup would try to back up itself; rclone would also reject it).
for SOURCE_PATH in "${SOURCE_PATHS[@]}"; do
  SOURCE_PATH="${SOURCE_PATH%/}"
  if [ "${BACKUP_DESTINATION}" = "${SOURCE_PATH}" ] || \
     [ "${BACKUP_DESTINATION#${SOURCE_PATH}/}" != "${BACKUP_DESTINATION}" ]; then
    catastrophicError "Destination '${BACKUP_DESTINATION}' is inside source '${SOURCE_PATH}'. Pick a destination outside every backed-up path."
  fi
done

printTitle "Destination: ${BACKUP_DESTINATION}"

## ============================================================================
## Make sure rclone is available (same behaviour as fxMirrorSsh)
## ============================================================================
if [ -z "$(command -v rclone)" ]; then
  printLightWarning "rclone is not installed. Installing it now..."
  curl https://rclone.org/install.sh | sudo bash
fi

if [ -z "$(command -v rclone)" ]; then
  catastrophicError "rclone is still not available after the install attempt"
fi

## ============================================================================
## Safety: the destination disk must be mounted (and not be the root fs)
## ============================================================================
assertDestinationOnSeparateDisk "${BACKUP_DESTINATION}"

## ============================================================================
## Create the destination, then take the lock
## ============================================================================
printTitle "📂 Creating the destination directory..."
mkdir -p "${BACKUP_DESTINATION}" || catastrophicError "Could not create destination '${BACKUP_DESTINATION}'"

lockCheck "${LOCK_NAME}" "${LOCK_TIMEOUT_MIN}"
## From here on always drop the lock when the script ends, however it ends
## (success, error, Ctrl+C). The trap is set only AFTER lockCheck succeeded, so
## we never delete a lock that belongs to another running instance.
trap 'removeLock "${LOCK_NAME}"' EXIT

## Capture the list of installed software before the (long) mirror starts.
dumpSystemManifest

## ============================================================================
## Build the rclone flag set once (aggressive profile, see fxMirrorSsh)
## ============================================================================
RCLONE_FLAGS=(
  --create-empty-src-dirs
  --links            ## copy symlinks AS symlinks; never follow them (do NOT use --copy-links/-L)
  --transfers 32 --checkers 64
  --retries 5 --low-level-retries 10
  --delete-excluded
  --log-level ERROR
)

## Live progress on a terminal; quiet, periodic one-line stats under cron.
IS_INTERACTIVE=0
if [ -t 1 ]; then
  IS_INTERACTIVE=1
  RCLONE_FLAGS+=( --progress )
else
  RCLONE_FLAGS+=( --stats=5m --stats-one-line )
fi

for EXCLUDE_PATTERN in "${RCLONE_EXCLUDES[@]}"; do
  RCLONE_FLAGS+=( --exclude "${EXCLUDE_PATTERN}" )
done

## ============================================================================
## Mirror every source path
## ============================================================================
BACKUP_FAILURES=0

for SOURCE_PATH in "${SOURCE_PATHS[@]}"; do

  SOURCE_PATH="${SOURCE_PATH%/}"
  printTitle "🪞 Mirroring ${SOURCE_PATH}"

  ## The source must exist and be a directory...
  if [ ! -d "${SOURCE_PATH}" ]; then
    printLightWarning "⏭️  '${SOURCE_PATH}' is not a directory: skipping"
    BACKUP_FAILURES=$((BACKUP_FAILURES + 1))
    continue
  fi

  ## ...and must NOT be empty. An empty source (e.g. a disk that failed to
  ## mount) would make `rclone sync` WIPE the matching backup, so we refuse to
  ## mirror it.
  if [ -z "$(ls -A "${SOURCE_PATH}" 2>/dev/null)" ]; then
    printLightWarning "⏭️  '${SOURCE_PATH}' is empty (not mounted?): skipping to protect the backup"
    BACKUP_FAILURES=$((BACKUP_FAILURES + 1))
    continue
  fi

  ## Mirror the CONTENTS of <source> into <destination><source>
  ##   e.g. /home  ->  ${BACKUP_DESTINATION}/home
  THIS_DESTINATION="${BACKUP_DESTINATION}${SOURCE_PATH}"
  if ! mkdir -p "${THIS_DESTINATION}"; then
    printLightWarning "⚠️  Could not create '${THIS_DESTINATION}': skipping ${SOURCE_PATH}"
    BACKUP_FAILURES=$((BACKUP_FAILURES + 1))
    continue
  fi

  RCLONE_COMMAND=( rclone sync "${RCLONE_FLAGS[@]}" "${SOURCE_PATH}" "${THIS_DESTINATION}" )

  echo "From: ${SOURCE_PATH}"
  echo "To:   ${THIS_DESTINATION}"
  echo ""
  echo "${RCLONE_COMMAND[@]}"
  echo ""

  ## Give a human the chance to abort (Ctrl+C) when running interactively.
  if [ "${IS_INTERACTIVE}" = 1 ]; then
    fxCountdown 5
  fi

  "${RCLONE_COMMAND[@]}"
  RCLONE_EXIT=$?

  if [ "${RCLONE_EXIT}" != 0 ]; then
    printLightWarning "⚠️  rclone exited with code ${RCLONE_EXIT} for ${SOURCE_PATH}"
    BACKUP_FAILURES=$((BACKUP_FAILURES + 1))
  else
    fxOK "${SOURCE_PATH} mirrored to ${THIS_DESTINATION}"
  fi
done

## ============================================================================
## Summary
## ============================================================================
if [ "${BACKUP_FAILURES}" -gt 0 ]; then
  printLightWarning "🛑 ${BACKUP_FAILURES} source path(s) FAILED or were skipped. See the log above."
  ## Non-zero exit so cron / monitoring notices. (The EXIT trap drops the lock.)
  exit 1
fi

printMessage "✅ Backup completed: all sources mirrored to ${BACKUP_DESTINATION}"
printTheEnd
