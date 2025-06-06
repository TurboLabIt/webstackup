#!/usr/bin/env bash
## Standard maintenance page activator by WEBSTACKUP
#
# How to:
#
# 1. In your Nginx server {}: `include /usr/local/turbolab.it/webstackup/config/nginx/06_maintenace.conf;`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/maintenance.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/refs/heads/master/my-app-template/scripts/maintenance.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy
#
# You can now `scripts/maintenance.sh on` and `scripts/maintenance.sh off`
#
# Tip: after the first `deploy.sh`, you can `zzmaintenance on` and `zzmaintenance off` directly

fxHeader "🧰 Nginx maintenance mode manager"

if [ "$1" = "on" ]; then

  fxTitle "🧰 ENGAGE maintenance mode..."
  sudo -u "${EXPECTED_USER}" -H touch "${WEBROOT_DIR}wsu-maintenance"

elif [ "$1" = "off" ]; then

  fxTitle "🌂 STOP maintenance mode..."
  sudo -u "${EXPECTED_USER}" -H rm -f "${WEBROOT_DIR}wsu-maintenance"

else

  fxCatastrophicError "❓ Usage: zzmaintenance on|off"
fi
