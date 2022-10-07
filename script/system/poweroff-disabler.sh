#!/usr/bin/env bash
## DISABLE THE POWEROFF/SHUTDOWN COMMAND BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/system/poweroff-disabler.sh?$(date +%s) | sudo bash
# 💡 To shutdown the system, you can then use `zzpoweroff`

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

MASK_FILE=/etc/systemd/system/poweroff.target

fxTitle "Checking current status..."
if [ -L "${MASK_FILE}" ] && [ $(readlink -f $MASK_FILE) = /dev/null ]; then
  fxInfo "Poweroff was ALREADY disabled on this system"
  fxEndFooter
fi

fxTitle "Disabling poweroff..."
systemctl mask poweroff.target

fxOK "Poweroff is now disabled"
fxMessage "To poweroff the system use zzpoweroff"

fxEndFooter
