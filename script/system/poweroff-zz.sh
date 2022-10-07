#!/usr/bin/env bash
## POWEROFF THE SYSTEM, BUT ONLY IT THE NORMAL POWEROFF COMMAND IS DISABLED BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/system/poweroff-zz.sh?$(date +%s) | sudo bash

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🔌 ZZPOWEROFF"
rootCheck

MASK_FILE=/etc/systemd/system/poweroff.target

fxTitle "Checking current status..."
if [ ! -L "${MASK_FILE}" ] || [ $(readlink -f $MASK_FILE) != /dev/null ]; then
  fxCatastrophicError "The poweroff command is not disabled on this server"
fi

fxTitle "Powering off..."
systemctl unmask poweroff.target
shutdown -P +1
systemctl mask poweroff.target

fxEndFooter
