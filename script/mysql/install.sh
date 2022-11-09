#!/usr/bin/env bash
### AUTOMATIC MYSQL INSTALL BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/install.sh?$(date +%s) | sudo MYSQL_VER=8.0 bash
#
# Based on: https://turbolab.it/1381

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 MySQL installer"
rootCheck

fxTitle "Removing any old previous instance..."
apt purge --auto-remove mysql* -y

fxTitle "Import an official signing key..."
curl https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/mysql/mysql.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/webstackup-mysql.gpg > /dev/null

fxTitle "Selecting the version..."
if [ -z "${MYSQL_VER}" ]; then

  MYSQL_VER=8.0
  fxImportantMessage "MYSQL_VER is not set - defaulting to MySQL ${MYSQL_VER}"

else

  fxInfo "Selecting the configured MYSQL_VER version, MySQL ${MYSQL_VER}"
fi


fxTitle "Setting up the repo..."
## https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#apt-repo-fresh-install

WSU_MYSQL_APT_FILE=/etc/apt/sources.list.d/webstackup.mysql.list

echo "### webstackup" > ${WSU_MYSQL_APT_FILE}

if [ "${MYSQL_VER}" = "5.7" ]; then

  WSU_MYSQL_LSB_RELEASE=bionic

  WSU_MYSQL_OS_VER_WARN="MySQL ${MYSQL_VER} is not available for new Ubuntu releases - Using repo for ${WSU_MYSQL_LSB_RELEASE}"
  fxImportantMessage "$WSU_MYSQL_OS_VER_WARN"
  echo "## $WSU_MYSQL_OS_VER_WARN" >> ${WSU_MYSQL_APT_FILE}

  WSU_MYSQL_OS_VER_WARN="Check: 22.04 http://repo.mysql.com/apt/ubuntu/dists/jammy/ vs 18.04 http://repo.mysql.com/apt/ubuntu/dists/bionic/"
  fxImportantMessage "$WSU_MYSQL_OS_VER_WARN"
  echo "## $WSU_MYSQL_OS_VER_WARN" >> ${WSU_MYSQL_APT_FILE}

else

  WSU_MYSQL_LSB_RELEASE=$(lsb_release -sc)
  fxInfo "Detected version: ${WSU_MYSQL_LSB_RELEASE}"
fi

WSU_MYSQL_APT_FILE=/etc/apt/sources.list.d/webstackup.mysql.list
echo "deb http://repo.mysql.com/apt/ubuntu/ $WSU_MYSQL_LSB_RELEASE mysql-${MYSQL_VER}" >> ${WSU_MYSQL_APT_FILE}
echo "deb-src http://repo.mysql.com/apt/ubuntu/ $WSU_MYSQL_LSB_RELEASE mysql-${MYSQL_VER}" >> ${WSU_MYSQL_APT_FILE}
echo "deb http://repo.mysql.com/apt/ubuntu/ $WSU_MYSQL_LSB_RELEASE mysql-tools" >> ${WSU_MYSQL_APT_FILE}

fxTitle "Set up repository pinning to prefer our packages over distribution-provided ones..."
echo -e "Package: *\nPin: origin repo.mysql.com\nPin: release o=mysql\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99mysql
  
fxTitle "Generating a random MySQL root password..."
MYSQL_ROOT_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password ${MYSQL_ROOT_PASSWORD}"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password ${MYSQL_ROOT_PASSWORD}"
debconf-set-selections <<< "mysql-community-server mysql-server/default-auth-override select"

fxTitle "Installing..."
apt update -qq
apt install mysql-server mysql-client -y -qq
  
fxTitle "Enabling Webstackup custom config for MySQL..."
WSU_MYSQL_SOURCE_CONFIG=${WEBSTACKUP_INSTALL_DIR}config/mysql/mysql.cnf
WSU_MYSQL_DEST_CONFIG=/etc/mysql/mysql.conf.d/webstackup.cnf

if [ ! -z "${WEBSTACKUP_INSTALL_DIR}" ] && [ -f "WSU_MYSQL_SOURCE_CONFIG" ]; then

  cp "${WSU_MYSQL_SOURCE_CONFIG}" "${WSU_MYSQL_DEST_CONFIG}"

else
  
  curl -Lo "${WSU_MYSQL_DEST_CONFIG}" "https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/mysql/mysql.cnf"
fi

if [ "${MYSQL_VER}" = "5.7" ]; then

  sed -i 's|mysqlx = off|#mysqlx = off|g' "${WSU_MYSQL_DEST_CONFIG}"
  sed -i 's|mysqlx-bind-address|#mysqlx-bind-address|g' "${WSU_MYSQL_DEST_CONFIG}"
fi


chmod u=rw,go=r /etc/mysql/mysql.conf.d/*.cnf


MYSQL_CREDENTIALS_DIR="/etc/turbolab.it/"
MYSQL_CREDENTIALS_FULLPATH="${MYSQL_CREDENTIALS_DIR}mysql.conf"
fxTitle "Saving MySQL root credentials to ${MYSQL_CREDENTIALS_FULLPATH}..."

mkdir -p "$MYSQL_CREDENTIALS_DIR"
echo "MYSQL_USER='root'" > "${MYSQL_CREDENTIALS_FULLPATH}"
echo "MYSQL_PASSWORD='$MYSQL_ROOT_PASSWORD'" >> "${MYSQL_CREDENTIALS_FULLPATH}"
echo "MYSQL_HOST=localhost" >> "${MYSQL_CREDENTIALS_FULLPATH}"
    
chown root:root "${MYSQL_CREDENTIALS_FULLPATH}"
chmod u=rw,go= "${MYSQL_CREDENTIALS_FULLPATH}"
  
fxMessage "$(cat "${MYSQL_CREDENTIALS_FULLPATH}")"

fxTitle "Restarting MySQL"
service mysql restart
systemctl --no-pager status mysql

if [ -f /usr/local/turbolab.it/webstackup/script/mysql/maintentance.sh ]; then
  cp /usr/local/turbolab.it/webstackup/config/cron/mysql /etc/cron.d/webstackup-mysql
fi

curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/mysqltuner.sh?$(date +%s) | sudo bash
