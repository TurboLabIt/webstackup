#!/usr/bin/env bash
## Magento maintenance page activator by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/maintenance.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/magento/maintenance-starter.sh && sudo chmod u=rwx,go=rx scripts/maintenance.sh
#
# 1. git commit your copy
#
# You can now `scripts/maintenance.sh on` and `scripts/maintenance.sh off`
#
# Tip: after the first `deploy.sh`, you can `zzmaintenance on` and `zzmaintenance off` directly

SCRIPT_NAME=maintenance

source $(dirname $(readlink -f $0))/script_begin.sh
fxHeader "🧰 Magento maintenance page manager"

if [ "$1" = "on" ]; then

  fxTitle "🧰 ENGAGE maintenance mode..."
  wsuMage maintenance:enable

elif [ "$1" = "off" ]; then

  fxTitle "🌂 STOP maintenance mode..."
  wsuMage maintenance:disable
  
else

  fxCatastrophicError "❓ Usage: zzmaintenance on|off"
fi

fxTitle "🌊 Magento cache:flush..."
wsuMage cache:flush
