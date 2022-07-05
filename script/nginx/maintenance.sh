#!/usr/bin/env bash
## Activate standard maintenace page by WEBSTACKUP
# printTitle "💫 Copying Nginx scripts from webstackup..."
# cp "${WEBSTACKUP_SCRIPT_DIR}nginx/maintenance.sh" "${SCRIPT_DIR}"

SCRIPT_NAME=maintenance

source $(dirname $(readlink -f $0))/script_begin.sh
fxHeader "🧰 Nginx maintenance mode manager"

if [ "$1" = "on" ]; then

  printTitle "🧰 ENGAGE maintenance mode..."
  sudo -u "${EXPECTED_USER}" -H touch "${WEBROOT_DIR}wsu-maintenance"

elif [ "$1" = "off" ]; then

  printTitle "🌂 STOP maintenance mode..."
  sudo -u "${EXPECTED_USER}" -H rm -f "${WEBROOT_DIR}wsu-maintenance"
  
else

  fxCatastrophicError "❓ Usage: zzmaintenance on|off"
fi

source $(dirname $(readlink -f $0))/script_end.sh
