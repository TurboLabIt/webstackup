#!/usr/bin/env bash
### AUTOMATIC Pure-FTPd INSTALL BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/pure-ftpd/install.sh?$(date +%s) | sudo bash
# sudo pure-pw useradd USERNAME_TO_ADD -u www-data -d /var/www && sudo pure-pw mkdb && sudo pure-pw list


## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "💿 Pure-FTPd installer "
rootCheck


fxTitle "Installing Pure-FTPd..."
apt update
apt install pure-ftpd  -y

fxTitle "Start Pure-FTPd at boot..."
systemctl enable pure-ftpd


fxTitle "www-data user setup..."
if id "www-data" &>/dev/null; then

  fxOK "www-data user found"
  
else

  fxTitle "Creating www-data group..."
  groupadd -f -r www-data
  
  fxTitle "Creating /var/www/..."
  mkdir -p /var/www
  
  fxTitle "Creating www-data..."
  useradd -g www-data -d /var/www -s /sbin/nologin -r www-data
  chown www-data:www-data /var/www -R
fi


fxTitle "/var/www/ setup"
if [ -d "/var/www" ]; then

  fxOK "/var/www/ found, skipping"
  
else

  mkdir -p /var/www
  chown www-data:www-data /var/www -R
fi


fxTitle "PassivePortRange setup..."
if [ ! -f "/etc/pure-ftpd/conf/PassivePortRange" ] && [ -f "/usr/local/turbolab.it/webstackup/config/pure-ftpd/PassivePortRange" ]; then

  fxTitle "Linking PassivePortRange config from Webstackup..."
  ln -s "/usr/local/turbolab.it/webstackup/config/pure-ftpd/PassivePortRange" "/etc/pure-ftpd/conf/PassivePortRange"

elif [ ! -f "/etc/pure-ftpd/conf/PassivePortRange" ]; then

  fxTitle "Downloading PassivePortRange config..."
  curl -Lo "/etc/pure-ftpd/conf/PassivePortRange" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/pure-ftpd/PassivePortRange
  
else

  fxOK "PassivePortRange exists, skipping"
fi


fxTitle "NoAnonymous setup..."
rm -f "/etc/pure-ftpd/conf/NoAnonymous"

if [ -f "/usr/local/turbolab.it/webstackup/config/pure-ftpd/Yes" ]; then

  fxTitle "Linking NoAnonymous config from Webstackup..."
  ln -s "/usr/local/turbolab.it/webstackup/config/pure-ftpd/Yes" "/etc/pure-ftpd/conf/NoAnonymous"

else

  fxTitle "Downloading NoAnonymous config..."
  curl -Lo "/etc/pure-ftpd/conf/NoAnonymous" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/pure-ftpd/Yes
fi


fxTitle "PureDB setup..."
rm -f "/etc/pure-ftpd/conf/PureDB"

if [ -f "/usr/local/turbolab.it/webstackup/config/pure-ftpd/PureDB" ]; then

  fxTitle "Linking PureDB config from Webstackup..."
  ln -s "/usr/local/turbolab.it/webstackup/config/pure-ftpd/PureDB" "/etc/pure-ftpd/conf/PureDB"

else

  fxTitle "Downloading PureDB config..."
  curl -Lo "/etc/pure-ftpd/conf/PureDB" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/pure-ftpd/PureDB
fi


fxTitle "Activating PureDB auth..."
if [ ! -f "/etc/pure-ftpd/auth/20PureDB" ]; then

  fxTitle "Linking PureDB auth config from Webstackup..."
  ln -s "/etc/pure-ftpd/conf/PureDB" "/etc/pure-ftpd/auth/20PureDB"
  
else

  fxOK "Auth exists, skipping"
fi


fxTitle "Disabling Unix auth..."
rm -f "/etc/pure-ftpd/conf/UnixAuthentication"
rm -f "/etc/pure-ftpd/conf/PAMAuthentication"

if [ -f "/usr/local/turbolab.it/webstackup/config/pure-ftpd/No" ]; then

  fxTitle "Linking Disabling Unix auth config from Webstackup..."
  ln -s "/usr/local/turbolab.it/webstackup/config/pure-ftpd/No" "/etc/pure-ftpd/conf/UnixAuthentication"
  ln -s "/usr/local/turbolab.it/webstackup/config/pure-ftpd/No" "/etc/pure-ftpd/conf/PAMAuthentication"

else

  fxTitle "Downloading isabling Unix auth config..."
  curl -Lo "/etc/pure-ftpd/conf/UnixAuthentication" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/pure-ftpd/No
  curl -Lo "/etc/pure-ftpd/conf/PAMAuthentication" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/pure-ftpd/No
fi


fxTitle "Configuring MinUID..."
rm -f "/etc/pure-ftpd/conf/MinUID"

if [ -f "/usr/local/turbolab.it/webstackup/config/pure-ftpd/MinUID" ]; then

  fxTitle "Linking MinUID config from Webstackup..."
  ln -s "/usr/local/turbolab.it/webstackup/config/pure-ftpd/MinUID" "/etc/pure-ftpd/conf/MinUID"

else

  fxTitle "Downloading MinUID config..."
  curl -Lo "/etc/pure-ftpd/conf/MinUID" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/pure-ftpd/MinUID
fi


fxTitle "Generating TLS certificate..."
mkdir -p "/etc/ssl/private/"

if [ ! -f "/etc/ssl/private/pure-ftpd.pem" ]; then

  openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout "/etc/ssl/private/pure-ftpd.pem" -out "/etc/ssl/private/pure-ftpd.pem" -subj "/CN=ftps"
  
else

  fxOK "Certificate file exists, skipping"
fi


fxTitle "Activate TLS..."
rm -f "/etc/pure-ftpd/conf/TLS"

if [ -f "/usr/local/turbolab.it/webstackup/config/pure-ftpd/TLS-only" ]; then

  fxTitle "Linking TLS config from Webstackup..."
  ln -s "/usr/local/turbolab.it/webstackup/config/pure-ftpd/TLS-only" "/etc/pure-ftpd/conf/TLS"

else

  fxTitle "Downloading TLS config..."
  curl -Lo "/etc/pure-ftpd/conf/TLS" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/pure-ftpd/TLS-only
fi


fxTitle "Listing config files..."
ls -lAtrh "/etc/pure-ftpd/conf"


fxTitle "Listing FTP users..."
if [ ! -f "/etc/pure-ftpd/pureftpd.passwd" ]; then
  touch "/etc/pure-ftpd/pureftpd.passwd"
fi
pure-pw mkdb
pure-pw list


fxTitle "Starting the service..."
service nginx restart
