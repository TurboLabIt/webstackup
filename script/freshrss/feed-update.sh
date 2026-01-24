#!/usr/bin/env bash
### AUTOMATIC FRESHRSS UPDATER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/freshrss/update.sh
#
# 📚 https://freshrss.github.io/FreshRSS/en/admins/08_FeedUpdates.html

source /usr/local/turbolab.it/webstackup/script/base.sh

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
