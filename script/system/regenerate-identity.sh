#!/usr/bin/env bash
### REGENERATE THE IDENTITY OF A CLONED VM by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/system/regenerate-identity.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/system/regenerate-identity.sh | sudo bash
#
# Run it ONCE on a VM just cloned from a template (Proxmox, ...): the clone boots with the SSH host keys
# and the machine-id of the template, so every clone looks like the same host (same SSH fingerprints,
# same DHCP DUID from systemd-networkd, journal and random-seed tied to a duplicated machine-id).
#
# What it does:
#   1. Deletes the SSH host keys, generates new ones (ssh-keygen -A), restarts sshd
#      (the current SSH session survives the restart: ssh.service has KillMode=process)
#   2. Deletes the machine-id, generates a new one (systemd-machine-id-setup)
#   3. Reboots
#
# On the next connection every SSH client complains "REMOTE HOST IDENTIFICATION HAS CHANGED": expected.
# Drop the old entry with `ssh-keygen -R <host>` and trust the new fingerprints printed by this script.

## bash-fx
if [ -z "$(command -v curl)" ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧬 REGENERATE IDENTITY (cloned VM: new SSH host keys + machine-id, then reboot)"
rootCheck

OLD_MACHINE_ID="$(cat /etc/machine-id 2>/dev/null)"

fxWarning "This gives ##$(hostname)## new SSH host keys and a new machine-id, then REBOOTS it"
fxInfo "Meant for a VM just cloned from a template: every SSH client will have to re-trust this host"
## from a terminal (zzsystem menu, local run): ask. Piped from curl: nothing to read, the countdown is the chance to abort
if [ -t 0 ]; then
  fxAskConfirmation "Proceed? [Y/N]"
else
  fxMessage "Last chance to abort with CTRL+C..."
  fxCountdown 10
fi


fxTitle "🔑 Regenerating the SSH host keys..."
rm -f /etc/ssh/ssh_host_*

## ssh-keygen -A exits 0 even when a key type fails: check the result on disk
ssh-keygen -A
if ! ls /etc/ssh/ssh_host_*_key > /dev/null 2>&1; then
  fxCatastrophicError "No ##/etc/ssh/ssh_host_*_key## after ##ssh-keygen -A##: sshd can't start without host keys. Fix it BEFORE closing this session or rebooting"
fi

fxOK "New host keys:"
for PUB_KEY in /etc/ssh/ssh_host_*_key.pub; do
  ssh-keygen -lf "$PUB_KEY"
done


fxTitle "🔄 Restarting sshd..."
if ! systemctl cat ssh.service > /dev/null 2>&1; then

  fxWarning "##ssh.service## not found (no openssh-server?): skipping the restart"

## the current SSH session survives: ssh.service has KillMode=process (only the listener is killed)
elif ! systemctl restart ssh; then

  fxCatastrophicError "sshd failed to restart (##journalctl -u ssh##): fix it BEFORE closing this session or rebooting, or you'll be locked out"

else

  fxOK "sshd restarted with the new keys"
fi


fxTitle "🆔 Regenerating the machine-id..."
fxInfo "Current machine-id: ##${OLD_MACHINE_ID}##"

## systemd-machine-id-setup generates a new ID only if /etc/machine-id is missing, and it copies the D-Bus ID
## first if it finds one: both files must go. /var/lib/dbus/machine-id is normally a symlink to /etc/machine-id,
## recreated at boot by tmpfiles.d/dbus.conf - on old releases it's a real file holding a copy of the ID
rm -f /etc/machine-id /var/lib/dbus/machine-id

## the new ID must be in place BEFORE rebooting: a missing /etc/machine-id at boot means "first boot" to systemd
## (ConditionFirstBoot=yes units run, systemd-firstboot may even prompt on the console).
## On a VM the new ID comes from the SMBIOS UUID (Proxmox assigns a new one to every clone), elsewhere it's random
if ! systemd-machine-id-setup; then
  fxCatastrophicError "##systemd-machine-id-setup## failed: do NOT reboot without a valid /etc/machine-id"
fi

NEW_MACHINE_ID="$(cat /etc/machine-id 2>/dev/null)"
if [ -z "$NEW_MACHINE_ID" ]; then
  fxCatastrophicError "##/etc/machine-id## is still missing or empty: do NOT reboot before fixing it"
fi

if [ "$NEW_MACHINE_ID" = "$OLD_MACHINE_ID" ]; then
  fxWarning "The machine-id didn't change (##${NEW_MACHINE_ID}##): on a VM it's derived from the SMBIOS UUID, so this VM probably kept the UUID of its source"
else
  fxOK "New machine-id: ##${NEW_MACHINE_ID}##"
fi


fxTitle "🔌 Rebooting..."
fxInfo "Everything (journal, DHCP DUID, ...) picks up the new machine-id at boot: rebooting in 3 seconds, this session will drop"

## in background + setsid: the script ends cleanly and the pending reboot outlives its terminal (same as zzupdate)
setsid bash -c "sleep 3; reboot" > /dev/null 2>&1 &

fxEndFooter
