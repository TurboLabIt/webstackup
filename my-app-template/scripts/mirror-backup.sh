#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/rsync-backup.sh

source $(dirname $(readlink -f $0))/script_begin.sh

MIRROR_REMOTE_USER="$(whoami)"
MIRROR_REMOTE_HOSTNAME="my-app.com"
MIRROR_LOCAL_DESTINATION_PATH="${PROJECT_DIR}backup/rsync-backup/"

mkdir -p "${MIRROR_LOCAL_DESTINATION_PATH}"

wsuMirrorDirectoryFromSsh "${MIRROR_REMOTE_USER}" "${MIRROR_REMOTE_HOSTNAME}" "/etc" "${MIRROR_LOCAL_DESTINATION_PATH}"
wsuMirrorDirectoryFromSsh "${MIRROR_REMOTE_USER}" "${MIRROR_REMOTE_HOSTNAME}" "/home" "${MIRROR_LOCAL_DESTINATION_PATH}"
wsuMirrorDirectoryFromSsh "${MIRROR_REMOTE_USER}" "${MIRROR_REMOTE_HOSTNAME}" "/var/www" "${MIRROR_LOCAL_DESTINATION_PATH}"

source "${SCRIPT_DIR}script_end.sh"

