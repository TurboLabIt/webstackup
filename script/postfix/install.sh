#!/usr/bin/env bash
### AUTOMATIC POSTFIX INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/postfix/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/postfix/install.sh | sudo POSTFIX_MAIL_NAME=mailserver.my-app.com bash
#
# Based on: https://turbolab.it/

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "💿 Postfix installer"
rootCheck


fxTitle "Removing any old previous instance..."
apt purge --auto-remove postfix* postfix mailutils opendkim opendkim-tools -y
rm -rf /etc/postfix /etc/config/opendkim/ /etc/opendkim.conf


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ ! -f "${WSU_DIR}setup.sh" ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "Automating..."
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
debconf-set-selections <<< "postfix postfix/mailname string ${POSTFIX_MAIL_NAME}"


fxTitle "Installing..."
apt update
apt install postfix mailutils opendkim opendkim-tools -y


fxMailNameWarning


fxTitle "Removing references to ##${POSTFIX_MAIL_NAME}## from mydestination..."
sed -i "s|${POSTFIX_MAIL_NAME}, ||g" /etc/postfix/main.cf
sed -i "s|${POSTFIX_MAIL_NAME},||g" /etc/postfix/main.cf


fxTitle "Replace default myhostname = $(hostname) with my own..."
sed -i '/^myhostname\|^mydestination/ s/^/#/' /etc/postfix/main.cf
echo "myhostname = ${POSTFIX_MAIL_NAME}" >> /etc/postfix/main.cf
echo "mydestination = localhost.localdomain, localhost" >>  /etc/postfix/main.cf


fxTitle "Appending default config..."
echo "" >>  /etc/postfix/main.cf
echo "" >>  /etc/postfix/main.cf
cat "${WEBSTACKUP_INSTALL_DIR}config/postfix/maincf_to_be_appended.conf" >> /etc/postfix/main.cf
echo "" >>  /etc/postfix/main.cf
echo "" >>  /etc/postfix/main.cf


fxTitle "Preparing aliases file..."
cp "${WEBSTACKUP_INSTALL_DIR}config/postfix/virtual-regexp.conf" /etc/postfix/virtual-regexp
sudo postmap /etc/postfix/virtual-regexp
chown root:root /etc/postfix/virtual-regexp*
chmod u=rw,go= /etc/postfix/virtual-regexp*


fxTitle "Preparing external relay password file..."
cp "${WEBSTACKUP_INSTALL_DIR}config/postfix/sasl_passwd.conf" /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd
chown root:root /etc/postfix/sasl_passw*
chmod u=rw,go= /etc/postfix/sasl_passw*


fxTitle "Adding the postfix user to the opendkim group..."
adduser postfix opendkim


fxTitle "Wiring together opendkim and postfix..."
cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/postfix_to_be_appended.conf" >> /etc/postfix/main.cf
echo "" >>  /etc/postfix/main.cf
echo "" >>  /etc/postfix/main.cf


mkdir /var/spool/postfix/opendkim
chown opendkim:postfix /var/spool/postfix/opendkim

sed -i -e 's|^UMask|#UMask|g' /etc/opendkim.conf
sed -i -e 's|^Socket|#Socket|g' /etc/opendkim.conf
echo "" >>  /etc/opendkim.conf
echo "" >>  /etc/opendkim.conf
echo "" >>  /etc/opendkim.conf
cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/opendkim_to_be_appended.conf" >> /etc/opendkim.conf

sed -i -e 's|^SOCKET=|#SOCKET=|g' /etc/default/opendkim
echo "" >> /etc/default/opendkim
echo "" >> /etc/default/opendkim
echo "" >> /etc/default/opendkim
cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/opendkim-default_to_be_appended.conf" >> /etc/default/opendkim

mkdir -p /etc/opendkim/keys

cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/TrustedHosts" /etc/opendkim/TrustedHosts
cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/KeyTable" /etc/opendkim/KeyTable
cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/SigningTable" /etc/opendkim/SigningTable

chown opendkim:opendkim /etc/opendkim/ -R
chmod ug=rwX,o=rX /etc/opendkim/ -R
chmod u=rwX,og=X /etc/opendkim/keys -R


fxTitle "Enabling SMTPS port for end-users to use..."
echo "" >>  /etc/postfix/master.cf
echo "" >>  /etc/postfix/master.cf
cat "${WEBSTACKUP_CONFIG_DIR}postfix/smtps-port-465.conf" | sed "s|my-app.com|${POSTFIX_MAIL_NAME}|g" >> /etc/postfix/master.cf


fxTitle "Restarting services..."
service postfix restart
service opendkim restart

fxEndFooter
