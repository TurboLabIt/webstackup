#!/usr/bin/env bash
## Standard Magento cache-clearing routine by WEBSTACKUP
# printTitle "💫 Copying Magento scripts from webstackup..."
# cp "${WEBSTACKUP_SCRIPT_DIR}frameworks/magento/cache-clear.sh" "${SCRIPT_DIR}"

SCRIPT_NAME=magento-cache-clear

source $(dirname $(readlink -f $0))/script_begin.sh
printHeader "🧹 cache-clear"

showPHPVer

fxTitle "Stopping services.."
sudo nginx -t && sudo service nginx stop && sudo service ${PHP_FPM} stop

wsuMage cache:flush

fxTitle "Restarting services.."
sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart

source "${SCRIPT_DIR}/script_end.sh"
