#!/usr/bin/env bash
### AUTOMATIC NGINX INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/nginx/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/nginx/install.sh?$(date +%s) | sudo bash
#
# Based on: https://turbolab.it/1482 | http://nginx.org/en/linux_packages.html#Ubuntu

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Nginx installer "
rootCheck

fxTitle "Removing any old previous instance..."
apt purge --auto-remove nginx* -y

## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ ! -f "${WSU_DIR}setup.sh" ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) | sudo bash
fi

source "${WSU_DIR}script/base.sh"

fxTitle "Installing prerequisites..."
apt update -qq
apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y

fxTitle "Installing additional utilities..."
apt install openssl zip unzip nano -y

fxTitle "Import an official nginx signing key..."
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

fxTitle "Verify that the downloaded file contains the proper key..."
gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

fxTitle "Selecting mainline..."
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

fxTitle "Set up repository pinning to prefer our packages over distribution-provided ones..."
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx


WWW_DIR=/var/www/
if [ ! -d "${WWW_DIR}" ]; then

  fxTitle "Creating ${WWW_DIR}..."
  mkdir -p "${WWW_DIR}"

  fxTitle "Setting the owner to www-data:www-data..."
  chown www-data:www-data "${WWW_DIR}" -R
  chmod u=rwX,g=rX,o= "${WWW_DIR}" -R

  fxTitle "SetGID - Any new file will have its group set to www-data"
  chmod g+s "${WWW_DIR}"
  FLAG_CHANGE_HOME=1

else

  fxInfo "${WWW_DIR} already exists, skipping"
fi

ls -lh "${WWW_DIR}"

fxTitle "Creating the autogenerated folder..."
mkdir -p "${WEBSTACKUP_AUTOGENERATED_DIR}"

fxTitle "Generating dhparam..."
openssl dhparam -out "${WEBSTACKUP_AUTOGENERATED_DIR}dhparam.pem" 2048 > /dev/null 2>&1 &

fxTitle "Generating the httpauth default file..."
HTTPAUTH_FULLFILE=${WEBSTACKUP_AUTOGENERATED_DIR}httpauth_welcome

echo -n 'wel:' > "$HTTPAUTH_FULLFILE"
openssl passwd -apr1 'come' >> "$HTTPAUTH_FULLFILE"
echo '' >> "$HTTPAUTH_FULLFILE"

echo -n 'ben:' >> "$HTTPAUTH_FULLFILE"
openssl passwd -apr1 'venuto' >> "$HTTPAUTH_FULLFILE"
echo '' >> "$HTTPAUTH_FULLFILE"

fxMessage "Ready-to-use HTTP credentials are:
User: wel | Pass: come
User: ben | Pass: venuto"


fxTitle "apt install nginx..."
apt update -qq
apt install nginx -y


if [ ! -z "${FLAG_CHANGE_HOME}" ]; then

  fxTitle "Changing www-data user home..."
  mkdir -p /home/www-data
  chown www-data:www-data /home/www-data -R
  chmod ug=rwx,o= /home/www-data -R
  usermod -d /home/www-data www-data
  fxOK "www-data home is now: $(echo ~www-data)"
fi


## Create a self-signed, bogus certificate
bash "${WEBSTACKUP_SCRIPT_DIR}https/self-sign-generate.sh" localhost

fxTitle "Disable HTTP: upgrade all connections to HTTPS..."
fxLink "${WEBSTACKUP_CONFIG_DIR}nginx/00_global_https_upgrade_all.conf" /etc/nginx/conf.d/

fxTitle "Disable the default website..."
if [ -f "/etc/nginx/conf.d/default.conf" ]; then
  mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d_default_original_backup.conf
fi

fxLink "${WEBSTACKUP_CONFIG_DIR}nginx/05_global_default_vhost_disable.conf" /etc/nginx/conf.d/

fxTitle "Activate the status_page..."
fxLink "${WEBSTACKUP_CONFIG_DIR}nginx/85_status_page.conf" /etc/nginx/conf.d/status_page.conf

fxTitle "Enabling the http-block level functionality"
fxLink "${WEBSTACKUP_CONFIG_DIR}nginx/02_global_http_level.conf" /etc/nginx/conf.d/

if [ ! -f "${WEBSTACKUP_AUTOGENERATED_DIR}nginx-php_ver.conf" ]; then

  fxTitle "PHP_VER file not found. Setting up a dummy one...."
  echo "set \$PHP_VER 99.99;"  >> "/usr/local/turbolab.it/webstackup/autogenerated/nginx-php_ver.conf"
fi


fxTitle "Final nginx restart..."
nginx -t
service nginx restart

fxEndFooter
