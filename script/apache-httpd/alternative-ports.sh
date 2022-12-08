#!/usr/bin/env bash
### MOVE APACHE TO ALTERNATIVE PORTS BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/apache-httpd/alternative-ports.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/apache-httpd/alternative-ports.sh?$(date +%s) | sudo bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🚪 Move Apache HTTP Server to alternative ports"
rootCheck


if [ -z "${APACHE_HTTPD_ALT_HTTP_PORT}" ]; then
  APACHE_HTTPD_ALT_HTTP_PORT=8080
fi

if [ -z "${APACHE_HTTPD_ALT_HTTPS_PORT}" ]; then
  APACHE_HTTPD_ALT_HTTPS_PORT=44344
fi


fxTitle "Backing up ports.conf..."
HTTPD_PORTS_BACKUP_FILE=/etc/apache2/ports_original_backup.conf
if [ ! -f "${HTTPD_PORTS_BACKUP_FILE}" ]; then
  mv /etc/apache2/ports.conf ${HTTPD_PORTS_BACKUP_FILE}
else
  fxWarning "The backup file already exists! Overwrite prevented"
fi

fxTitle "Replacing ports.conf..."
echo "## 🚪 Nulled by WSU alternative-ports.sh" > /etc/apache2/ports.conf
echo "# The original file was backed up into ##${HTTPD_PORTS_BACKUP_FILE}##" >> /etc/apache2/ports.conf


fxTitle "Generating alternative-ports.conf..."
echo "Listen ${APACHE_HTTPD_ALT_HTTP_PORT}" > /etc/apache2/conf-available/alternative-ports.conf
echo "Listen ${APACHE_HTTPD_ALT_HTTPS_PORT}" >> /etc/apache2/conf-available/alternative-ports.conf

fxTitle "Activate alternative-ports..."
a2enconf alternative-ports


function wsuApacheAltPortFileManager()
{
  local FILE=$1
  
  fxTitle "Replacing symlink $(basename $FILE) with a copy..."
  if [ -e "${FILE}" ]; then
  
    fxReplaceLinkWithCopy "${FILE}"
    
  else
  
    fxWarning "##${FILE}## doesn't exist! Skipping..."
    return 1
    
  fi


  fxTitle "Replacing listening ports in $(basename $FILE)..."
  sed -i "s|80|${APACHE_HTTPD_ALT_HTTP_PORT}|" "${FILE}"
  sed -i "s|443|${APACHE_HTTPD_ALT_HTTPS_PORT}|" "${FILE}"
}

wsuApacheAltPortFileManager /etc/apache2/sites-available/00_global_https_upgrade_all.conf
wsuApacheAltPortFileManager /etc/apache2/sites-available/05_global_default_vhost_disable.conf


fxTitle "Final restart..."
apachectl configtest
service apache2 restart

fxTitle "Status..."
ss -lpt | grep -i apache

fxEndFooter
