#!/usr/bin/env bash
### AUTOMATIC FRESHRSS UPDATER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/freshrss/update.sh
#
# 📚 https://freshrss.github.io/FreshRSS/en/admins/08_FeedUpdates.html

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📰 FreshRSS feed updater"
rootCheck

FRESHRSS_INSTALL_DIR=/var/www/freshrss/

fxTitle "Application check..."
if [ ! -d "${FRESHRSS_INSTALL_DIR}" ]; then
  fxCatastrophicError "##${FRESHRSS_INSTALL_DIR}## not found!"
fi


source /usr/local/turbolab.it/webstackup/script/php/version-variables.sh
showPHPVer

fxTitle "Updating..."
sudo -u www-data -H $PHP_CLI -f ${FRESHRSS_INSTALL_DIR}app/actualize_script.php


fxEndFooter
