#!/usr/bin/env bash
## Standard Symfony cache-clearing routine by WEBSTACKUP
#
# How to:
#
# 1. In your Nginx server {}: `include /usr/local/turbolab.it/webstackup/config/nginx/06_maintenace.conf;`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo script/maintenance.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/nginx/maintenance-starter.sh && sudo chmod u=rwx,go=rx script/maintenance-starter.sh
#
# 1. You should now git commit your copy
#
# You can now `script/maintenance.sh on` and `script/maintenance.sh off`
#
# Tip: after the first `deploy.sh`, you can ``zzmaintenance on` and `zzmaintenance off` directly

SCRIPT_NAME=maintenance

source $(dirname $(readlink -f $0))/script_begin.sh
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
