#!/usr/bin/env bash
### AUTOMATIC PHP INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/php/install.sh
#
# sudo apt update && apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php/install.sh?$(date +%s) | sudo PHP_VER=8.3 bash
#
# Based on: https://turbolab.it/1380

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 PHP installer"
rootCheck

if [ -z "${PHP_VER}" ]; then
  fxCatastrophicError "PHP_VER is undefined! Cannot determine which version of PHP to install"
fi


## checking compatibility
# https://github.com/TurboLabIt/webstackup/issues/15
fxTitle "Checking OS version..."
apt update
apt install lsb-release -y
RELEASE_DESCR=$(lsb_release -d)
echo ""
fxMessage "${RELEASE_DESCR}"
echo ""

if [[ "$RELEASE_DESCR" == *"Ubuntu"* ]] && [[ "$RELEASE_DESCR" == *"LTS"* ]]; then
  
  PHP_OS_DETECTED=ubuntu
  fxOK "Ubuntu LTS detected"

elif [[ "$RELEASE_DESCR" == *"Debian"* ]]; then

  PHP_OS_DETECTED=debian
  fxOK "Debian detected"

else

  fxCatastrophicError "The OS is INCOMPATIBLE with this script! See: https://github.com/TurboLabIt/webstackup/issues/15"
fi


fxTitle "Removing any old previous instance of PHP ${PHP_VER} (if any)..."
fxInfo "Note: this will display some errors if PHP is not installed yet."
fxInfo "This is expected, don't freak out"
apt purge --auto-remove php${PHP_VER}* -y
rm -rf /etc/php/${PHP_VER} /var/log/php${PHP_VER}*


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ ! -f "${WSU_DIR}setup.sh" ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) | sudo bash
fi

PHP_VER_REQUESTED=${PHP_VER}
source "${WSU_DIR}script/base.sh"
PHP_VER=${PHP_VER_REQUESTED}


fxTitle "Installing prerequisites..."
apt update -qq
apt install software-properties-common ca-certificates apt-transport-https  -y


fxTitle "Setting up ondrej/php..."
if [ "${PHP_OS_DETECTED}" == 'ubuntu' ]; then
  
  
  LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y


elif [ "${PHP_OS_DETECTED}" == 'debian' ]; then

  sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/webstackup-php-debian.list' 
  curl https://packages.sury.org/php/apt.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/webstackup-php-sury.gpg > /dev/null

fi


apt update -qq


fxTitle "Installing..."
apt install -y \
  php${PHP_VER}-cli php${PHP_VER}-common php${PHP_VER}-fpm \
  php${PHP_VER}-bcmath php${PHP_VER}-curl \
  php${PHP_VER}-gd php${PHP_VER}-imagick \
  php${PHP_VER}-intl php${PHP_VER}-mbstring \
  php${PHP_VER}-mysql \
  php${PHP_VER}-soap php${PHP_VER}-xml \
  php${PHP_VER}-zip


fxTitle "Config path"
FPM_CONF_FILE=/etc/php/${PHP_VER}/fpm/conf.d/30-webstackup-
CLI_CONF_FILE=/etc/php/${PHP_VER}/cli/conf.d/30-webstackup-
echo "FPM file(s): ${FPM_CONF_FILE}"
echo "CLI file(s): ${CLI_CONF_FILE}"


wsuMkAutogenDir


fxTitle "Storing the selected version..."
echo "set \$PHP_VER ${PHP_VER};"  > "${WEBSTACKUP_AUTOGENERATED_DIR}nginx-php_ver.conf"
echo "PHP_VER=${PHP_VER}" >> "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"
echo "PHP_FPM=php${PHP_VER}-fpm" >> "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"
echo "PHP_CLI=/usr/bin/php${PHP_VER}" >> "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"


fxTitle "Activating custom php.ini for FPM..."  
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/php-custom.ini" ${FPM_CONF_FILE}custom.ini

fxTitle "Disabling execution function from FPM..."  
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/no-exec.ini" ${FPM_CONF_FILE}no-exec.ini

fxTitle "Setting timezone to Italy..."
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/timezone-italy.ini" ${FPM_CONF_FILE}timezone-italy.ini
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/timezone-italy.ini" ${CLI_CONF_FILE}timezone-italy.ini
echo ""
fxInfo "Different timezone? rm -rf ${FPM_CONF_FILE}timezone-italy.ini ${CLI_CONF_FILE}timezone-italy.ini"

fxTitle "Removing all limits from CLI..."
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/unlimited.ini" ${CLI_CONF_FILE}unlimited.ini

fxTitle "Disable cgi.fix_pathinfo from FPM..."
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/no-cgi.fix_pathinfo.ini" ${FPM_CONF_FILE}no-cgi.fix_pathinfo.ini

fxTitle "Enable OPcache..."
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/opcache.ini" ${FPM_CONF_FILE}opcache.ini

fxTitle "Configuring Xdebug..."
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/xdebug.ini" ${FPM_CONF_FILE}xdebug.ini
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/xdebug.ini" ${CLI_CONF_FILE}xdebug.ini
echo ""
fxInfo "Xdebug is configured, but NOT installed. To install it: sudo apt install php${PHP_VER}-xdebug install -y"


fxTitle "Activating custom php-fpm pool settings..."
POOL_LINK=/etc/php/${PHP_VER}/fpm/pool.d/zz_webstackup-fpm-pool.conf

if [ "$INSTALLED_RAM" -gt "16000" ]; then

  echo "RAM: ${INSTALLED_RAM} MB: using fpm-pool-32GB.conf"
  fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/fpm-pool-32GB.conf" ${POOL_LINK}

elif [ "$INSTALLED_RAM" -gt "8000" ]; then

  echo "RAM: ${INSTALLED_RAM} MB: using fpm-pool-16GB.conf"
  fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/fpm-pool-16GB.conf" ${POOL_LINK}

else

  echo "RAM: ${INSTALLED_RAM} MB: this is a small server! Using fpm-pool-1GB.conf"
  fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/fpm-pool-1GB.conf" ${POOL_LINK}
fi


fxTitle "Create the socket directory..."
mkdir -p /run/php/


fxTitle "Starting php-fpm service..."
/usr/sbin/php-fpm${PHP_VER} -t && service php${PHP_VER}-fpm restart
systemctl --no-pager status php${PHP_VER}-fpm

  
fxTitle "Linking the PHP-FPM socket as php-fpm.sock..."
if [ ! -e "/run/php/php-fpm.sock" ]; then

  fxLink /run/php/php${PHP_VER}-fpm.sock /run/php/php-fpm.sock

else

  fxInfo "Link already exists"
  ls -l "/run/php/php-fpm.sock"
fi


fxTitle "Enabling PHP integration with Apache HTTP Server..."
if [ -d /etc/apache2/ ] && [ ! -z $(command -v a2enconf) ]; then

  ## https://turbolab.it/1961
  a2dismod php* -f
  apt purge libapache2-mod-php* -y
  apt install libapache2-mod-fcgid -y
  a2enmod proxy_fcgi setenvif
  rm -f /etc/apache2/mods-available/dir.conf
  
else

  fxInfo "Function disabled or Apache HTTP Server not installed, skipping"  
fi


## enabling PHP globally on Apache is not always desirable, b/c it forces the same PHP version for every vhost
if [ ! -z "${APACHE_PHP_GLOBAL_ENABLE}" ] && [ -d /etc/apache2/ ] && [ ! -z $(command -v a2enconf) ]; then

  a2enconf ${PHP_FPM}
  apachectl configtest && service apache2 restart
  
else

  fxInfo "Function disabled or Apache HTTP Server not installed, skipping"  
fi


fxEndFooter
