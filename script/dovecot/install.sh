#!/usr/bin/env bash
### AUTOMATIC DOVECOT INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/dovecot/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/dovecot/install.sh?$(date +%s) | sudo POSTFIX_MAIL_NAME=my-app.com bash
#
# Based on: https://turbolab.it/

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Dovecot installer"
rootCheck

fxTitle "Removing any old previous instance..."
#apt purge --auto-remove dovecot* -y
#rm -rf /etc/dovecot

## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ ! -f "${WSU_DIR}setup.sh" ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) | sudo bash
fi

source "${WSU_DIR}script/base.sh"

fxTitle "Installing..."
apt update
apt install dovecot-lmtpd dovecot-imapd dovecot-pop3d -y

fxTitle "Creating the vmail user..."
useradd --no-create-home --shell /bin/false --system vmail

fxTitle "Creating the mail store directories..."
mkdir -p /var/lib/dovecot/vmail
chown vmail:vmail /var/lib/dovecot/vmail -R
chmod ugo= /var/lib/dovecot/vmail -R
chmod ug=rwX,o= /var/lib/dovecot/vmail -R
fxOK "Mailstore created at #/var/lib/dovecot/vmail#"

fxTitle "Creating the logfiles..."
touch /var/log/dovecot.log
chown vmail:vmail /var/log/dovecot.log
chmod ug=rw,o= /var/log/dovecot.log

touch /var/log/dovecot-info.log
chown vmail:vmail /var/log/dovecot-info.log
chmod ug=rw,o= /var/log/dovecot-info.log

fxOK "Log files created"
fxMessage "Use #tail -f /var/log/dovecot* /var/log/mail.log# to see the logs"

fxTitle "Linking the Webstackup config..."
fxLink "${WEBSTACKUP_CONFIG_DIR}dovecot/virtual-users.conf" /etc/dovecot/conf.d/00-webstackup.conf

fxTitle "Installing Postfix..."
if [ ! -f /usr/sbin/postfix ]; then
  POSTFIX_MAIL_NAME=${POSTFIX_MAIL_NAME} bash ${WEBSTACKUP_SCRIPT_DIR}postfix/install.sh
else
  fxInfo "Postfix is aready installed"
  fxEndFooter
fi
