#!/bin/bash

source "$(dirname "$(readlink -f "$0")")/base.sh"

fxHeader "📚 DEPLOY NEW SERVER"
rootCheck

fxTitle "Loading default config..."
source ${WEBSTACKUP_INSTALL_DIR}webstackup.default.conf

## Default config error!
if [[ $WEBSTACKUP_ENABLED != 1 ]]; then
  catastrophicError "Default config file not available or script disabled"
fi


## Config file from CLI
CONFIGFILE_FULLPATH=$1
if [ ! -z "$CONFIGFILE_FULLPATH" ] && [ ! -f "$CONFIGFILE_FULLPATH" ]; then

  catastrophicError "Config file not found!
Please check if the following file exists and is accessible:

$CONFIGFILE_FULLPATH"

fi


## Config file from CLI OK
if [ ! -z "$CONFIGFILE_FULLPATH" ]; then

  fxTitle "Importing custom options"
  source "$CONFIGFILE_FULLPATH"

  fxMessage "Custom options imported from $CONFIGFILE_FULLPATH"

else

  CONFIGFILE_NAME=webstackup.conf
  CONFIGFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_NAME

  for CONFIGFILE_FULLPATH in "$CONFIGFILE_FULLPATH_ETC"
  do
    if [ -f "$CONFIGFILE_FULLPATH" ]; then
      source "$CONFIGFILE_FULLPATH"
    fi
  done
fi


if [ "$INSTALL_PHP" = 1 ]; then
  ## https://github.com/TurboLabIt/webstackup/issues/15
  fxRequireCompatbileUbuntuVersion "${COMPATIBLE_OS_VERSIONS}"
fi


fxTitle "Installing WEBSTACK.UP..."
if [ "$INSTALL_WEBSTACKUP" = 1 ]; then

  fxMessage "Installing dependencies..."
  apt update
  apt install git software-properties-common gnupg2 dialog htop screen openssl zip unzip rsyslog -y

  wsuMkAutogenDir
  >"${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"

  ## webstackup user + SSH keys
  bash ${WEBSTACKUP_SCRIPT_DIR}account/generate-www-data.sh

  fxMessage "Keep SSH alive..." 
  ln -s ${WEBSTACKUP_INSTALL_DIR}config/ssh/keepalive.conf /etc/ssh/sshd_config.d/webstackup-keepalive.conf

  fxMessage "Faster SSH login..."
  ln -s ${WEBSTACKUP_INSTALL_DIR}config/ssh/faster-login.conf /etc/ssh/sshd_config.d/webstackup-faster-login.conf

  fxMessage "Change SSH port (template)"
  curl -o /etc/ssh/sshd_config.d/port.conf https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/ssh/port.conf

  fxMessage "SFTP-only group..."
  addgroup sftp-only
  ln -s ${WEBSTACKUP_INSTALL_DIR}config/ssh/sftp-only-group.conf /etc/ssh/sshd_config.d/webstackup-sftp-only-group.conf

  fxMessage "Updating MOTD"
  source "${WEBSTACKUP_SCRIPT_DIR}motd/setup.sh"

else

  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Changing hostname..."
if [ ! -z "$INSTALL_HOSTNAME" ]; then

  hostnamectl set-hostname ${INSTALL_HOSTNAME}
  hostnamectl set-hostname ${INSTALL_HOSTNAME} --static
  echo "127.0.0.1   ${INSTALL_HOSTNAME}" >> /etc/hosts
  fxOK "Hostname is now: $(hostname)"

else

  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing cron..."
if [ "$INSTALL_CRON" = 1 ]; then

  apt install cron -y -qq

  fxTitle "Deploying webstackup cron file..."
  cp "${WEBSTACKUP_INSTALL_DIR}config/cron/webstackup" /etc/cron.d/
fi


fxTitle "Set the timezone..."
if [ ! -z "$INSTALL_TIMEZONE" ]; then

  timedatectl set-timezone $INSTALL_TIMEZONE
  service syslog restart
  service cron restart
fi


fxTitle "Installing NGINX..."
if [ "$INSTALL_NGINX" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}nginx/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing Apache HTTP Server..."
if [ "$INSTALL_APACHE_HTTPD" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}apache-httpd/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing Apache HTTP Server alternative ports..."
if [ "$INSTALL_APACHE_HTTPD_ALT_PORTS" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}apache-httpd/alternative-ports.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing PHP..."
if [ "$INSTALL_PHP" = 1 ]; then
  PHP_VER=${PHP_VER} bash ${WEBSTACKUP_SCRIPT_DIR}php/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing MySQL..."
if [ "$INSTALL_MYSQL" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}mysql/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing Varnish..."
if [ "$INSTALL_VARNISH" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}varnish/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing Node.js..."
if [ "$INSTALL_NODEJS" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}node.js/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ELASTICSEARCH..."
if [ "$INSTALL_ELASTICSEARCH" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}elasticsearch/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing PURE-FTPD..."
if [ "$INSTALL_PUREFTPD" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}pure-ftpd/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing COMPOSER..."
if [ "$INSTALL_COMPOSER" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}php/composer-install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing SYMFONY..."
if [ "$INSTALL_SYMFONY" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}frameworks/symfony/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ZZUPDATE..."
if [ "$INSTALL_ZZUPDATE" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzupdate/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ZZMYSQLDUMP"
if [ "$INSTALL_ZZMYSQLDUMP" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzmysqldump/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing pbpBB Upgrader"
if [ "$INSTALL_PHPBB_UPGRADER" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/phpbb-upgrader/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing XDEBUG..."
if [ "$INSTALL_XDEBUG" = 1 ]; then

  fxMessage "Installing..."
  apt install php-xdebug -y -qq

  service php${PHP_VER}-fpm restart

else

  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing LET'S ENCRYPT..."
if [ $INSTALL_LETSENCRYPT = 1 ]; then

  fxMessage "Installing..."
  apt install certbot -y -qq
  fxMessage "$(certbot --version)"
  service cron restart
  source "${WEBSTACKUP_SCRIPT_DIR}https/letsencrypt-create-hooks.sh"

else

  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing POSTFIX and OPENDKIM"
if [ "$INSTALL_POSTFIX" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}postfix/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing DOVECOT"
if [ "$INSTALL_DOVECOT" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}dovecot/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ZZALIAS..."
if [ "$INSTALL_ZZALIAS" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzalias/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Firewalling..."
if [ "$INSTALL_FIREWALL" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzfirewall/master/setup.sh | sudo bash
  sudo zzfirewall
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ZZDDNS..."
if [ "$INSTALL_ZZDDNS" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzddns/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Creating users..."
if [ ! -z "$INSTALL_USERS_TEMPLATE_PATH" ]; then
  bash "${WEBSTACKUP_SCRIPT_DIR}account/create_and_copy_template.sh" "$INSTALL_USERS_TEMPLATE_PATH"
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Disable SSH password login..."
if [ "$INSTALL_SSH_DISABLE_PASSWORD_LOGIN" = 1 ]; then
  ln -s "${WEBSTACKUP_INSTALL_DIR}config/ssh/disable-password-login.conf" /etc/ssh/sshd_config.d/webstackup-disable-password-login.conf
else

  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing CHROME..."
if [ "$INSTALL_CHROME" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}chrome/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing PDF SUPPORT..."
if [ "$INSTALL_PDF_SUPPORT" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}script/print/install-pdf.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Running cloning wizard..."
if [ "$INSTALL_GIT_CLONE_WEBAPP" = 1 ]; then

  bash ${WEBSTACKUP_SCRIPT_DIR}mysql/new.sh
  bash ${WEBSTACKUP_SCRIPT_DIR}filesystem/git-clone.sh

else

  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing and running benchmark..."
if [ "$INSTALL_BENCHMARK" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}performance/benchmark.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Running Poweroff disabler..."
if [ "$INSTALL_DISABLE_POWEROFF" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}power/poweroff-disabler.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Restarting SSH..."
sshd -t && service sshd restart


fxTitle "REBOOTING..."
if [ "$REBOOT" = "1" ] && [ "$INSTALL_ZZUPDATE" = 1 ]; then

  fxCountdown
  zzupdate

elif [ "$REBOOT" = "1" ]; then

  fxCountdown
  shutdown -r -t 5

else

  fxInfo "Skipped (disabled in config)"
fi


fxEndFooter
