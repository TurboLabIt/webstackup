#!/usr/bin/env bash
### AUTOMATIC APACHE HTTP SERVER INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/apache-httpd/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/apache-httpd/install.sh?$(date +%s) | sudo bash
#
# Based on: https://turbolab.it/1379

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Apache HTTP Server installer"
rootCheck

fxTitle "Removing any old previous instance..."
apt purge --auto-remove apache2* -y 
rm -rf /etc/apache2

## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ ! -f "${WSU_DIR}setup.sh" ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) | sudo bash
fi

source "${WSU_DIR}script/base.sh"

bash ${WEBSTACKUP_SCRIPT_DIR}account/generate-www-data.sh

wsuMkAutogenDir

fxTitle "Generating dhparam..."
openssl dhparam -out "${WEBSTACKUP_AUTOGENERATED_DIR}dhparam.pem" 2048 > /dev/null 2>&1 &

bash ${WEBSTACKUP_SCRIPT_DIR}account/generate-http-basic-auth.sh


fxTitle "apt install apache..."
apt update -qq
apt install apache2 libapache2-mod-fcgid -y


fxTitle "Disable Prefork and Worker MPMs..."
a2dismod mpm_prefork mpm_worker

fxTitle "Enable Apache Event module..."
a2enmod mpm_event

fxTitle "Enable HTTP/2 support...."
a2enmod http2


fxTitle "Disable mod_php (if any)..."
a2dismod php*

fxTitle "Enable Apache FastCGI module (for PHP)..."
a2enmod proxy_fcgi setenvif

fxTitle "Enabling ${PHP_FPM} support..."
## enabling PHP globally is not desirable, b/c it forces the same version for every vhost
if [ ! -z "${APACHE_PHP_GLOBAL_ENABLE}" ] && [ ! -z "${PHP_VER}" ] && [ ! -z "${PHP_FPM}" ]; then
  a2enconf ${PHP_FPM}
else
  fxInfo "Function disabled or PHP not found, skipping"  
fi

fxTitle "Disable the default Apache vhost configuration..."
a2dissite 000-default

## ... TO BE CONTINUED ...

fxTitle "Final restart..."
apachectl configtest
service apache2 restart

fxEndFooter