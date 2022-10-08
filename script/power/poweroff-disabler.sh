#!/usr/bin/env bash
## DISABLE THE POWEROFF/SHUTDOWN COMMAND BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/power/poweroff-disabler.sh?$(date +%s) | sudo bash
# 💡 To shutdown the system, you must then use `zzserver-poweroff`
#
# Source: https://turbolab.it/23

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🔌 Poweroff disabler"
rootCheck


fxTitle "Checking current status..."
MASK_FILE=/etc/systemd/system/poweroff.target

if [ -L "${MASK_FILE}" ] && [ $(readlink -f $MASK_FILE) = /dev/null ]; then

  fxOK "Poweroff was ALREADY disabled on this system"
  
else

  fxTitle "Disabling poweroff..."
  systemctl mask poweroff.target

  echo ""
  fxOK "Poweroff is now disabled"
fi


fxTitle "Deploying @reboot cron..."
CRON_FILE=/etc/cron.d/webstackup_poweroff_disabler
rm -f "${ZZPOWEROFF_FILE}"
mkdir -p "/var/log/turbolab.it"

if [ -f "${WSU_CRON_FILE}" ]; then

  fxTitle "Copying..."
  cp "/usr/local/turbolab.it/webstackup/config/cron/poweroff-disabler" "${CRON_FILE}"
  
else

  fxTitle "Downloading..."
  curl -o "${CRON_FILE}" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/cron/poweroff-disabler?$(date +%s)
fi


fxTitle "Checking zzserver-poweroff..."
ZZPOWEROFF_FILE="/usr/local/bin/zzserver-poweroff"
rm -f "${ZZPOWEROFF_FILE}"
WSU_POWEROFF=/usr/local/turbolab.it/webstackup/script/system/poweroff-zz.sh

if [ -f "${WSU_POWEROFF}" ]; then

  fxLinkBin "${WSU_POWEROFF}" "${ZZPOWEROFF_FILE}"
  
else

  fxTitle "Downloading..."
  curl -o "${ZZPOWEROFF_FILE}" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/power/poweroff-zz.sh?$(date +%s)
  chown root:root "${ZZPOWEROFF_FILE}"
  chmod u=rwx,go=rx "${ZZPOWEROFF_FILE}"
fi


echo ""
fxMessage "💡 To poweroff the system use zzserver-poweroff"

fxEndFooter
