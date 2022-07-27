#!/usr/bin/env bash
## Activate standard maintenace page by WEBSTACKUP
#
# 1. In your project `script_begin.sh`: `USE_NGINX_MAINTENANCE=1`
# 1. In your server {}: `include /usr/local/turbolab.it/webstackup/config/nginx/06_maintenace.conf;`
# 1. Run your `deploy.sh` at least once
# 1. You can now `zzmaintenance on` and `zzmaintenance off`

SCRIPT_NAME=maintenance

source $(dirname $(readlink -f $0))/script_begin.sh
printHeader "🧰 Nginx maintenance mode manager"

if [ "$1" = "on" ]; then

  printTitle "🧰 ENGAGE maintenance mode..."
  sudo -u "${EXPECTED_USER}" -H touch "${WEBROOT_DIR}wsu-maintenance"

elif [ "$1" = "off" ]; then

  printTitle "🌂 STOP maintenance mode..."
  sudo -u "${EXPECTED_USER}" -H rm -f "${WEBROOT_DIR}wsu-maintenance"
  
else

  catastrophicError "❓ Usage: zzmaintenance on|off"
fi

source $(dirname $(readlink -f $0))/script_end.sh
