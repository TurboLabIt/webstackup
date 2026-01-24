#!/usr/bin/env bash
### AUTOMATIC FRESHRSS UPDATER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/freshrss/update.sh
#
# 📚 https://freshrss.github.io/FreshRSS/en/admins/07_LinuxUpdate.html

source /usr/local/turbolab.it/webstackup/script/base.sh

fxHeader "💿 FreshRSS updater"
rootCheck

FRESHRSS_INSTALL_DIR=/var/www/freshrss/

fxTitle "Application check..."
if [ ! -d "${FRESHRSS_INSTALL_DIR}" ]; then
  fxCatastrophicError "##${FRESHRSS_INSTALL_DIR}## not found!"
fi


function freshrssSetWebPermissions()
{
  fxTitle "Setting permissions on ##${FRESHRSS_INSTALL_DIR}##..."
  chown www-data:www-data "${FRESHRSS_INSTALL_DIR}" -R
  chmod ugo= "${FRESHRSS_INSTALL_DIR}" -R
  chmod ug=rwX,o=rX "${FRESHRSS_INSTALL_DIR}" -R
}

freshrssSetWebPermissions


fxTitle "Switching to ##${FRESHRSS_INSTALL_DIR}##..."
cd "${FRESHRSS_INSTALL_DIR}"
fxOK "##$(pwd)##"


fxTitle "Git stuff..."
sudo -u www-data -H git fetch --all
sudo -u www-data -H git reset --hard
sudo -u www-data -H git clean -f -d
sudo -u www-data -H git pull --ff-only
sudo -u www-data -H git status


freshrssSetWebPermissions


# https://github.com/TurboLabIt/webstackup/blob/master/script/php/version-variables.sh
source /usr/local/turbolab.it/webstackup/script/php/version-variables.sh
showPHPVer

fxTitle "Restaring PHP-FPM (flush opcache)..."
service $PHP_FPM restart


fxEndFooter
