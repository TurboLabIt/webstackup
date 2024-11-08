#!/usr/bin/env bash
## Magento maintenance page activator by WEBSTACKUP
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=magento` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/maintenance.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. git commit your copy
#
# You can now `scripts/maintenance.sh on` and `scripts/maintenance.sh off`
#
# Tip: after the first `deploy.sh`, you can `zzmaintenance on` and `zzmaintenance off` directly

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


systemctl --all --type service | grep -q "varnish"
if [ "$?" = 0 ]; then
  fxTitle "🔃 Restarting Varnish..."
  sudo service varnish restart
fi
