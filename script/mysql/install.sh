#!/usr/bin/env bash
### AUTOMATIC MYSQL INSTALL BY WEBSTACK.UP

if ! [ $(id -u) = 0 ]; then

    echo "This script must run as ROOT"
    exit
fi

echo -e "\e[1;45m Removing previous version (if any) \e[0m"
apt purge --auto-remove mysql* -y -qq

echo -e "\e[1;45m Setting up the repo... \e[0m"
# https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#apt-repo-fresh-install
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3A79BD29

touch /etc/apt/sources.list.d/webstackup.mysql.list
echo "### webstackup" >> /etc/apt/sources.list.d/webstackup.mysql.list
echo "deb http://repo.mysql.com/apt/ubuntu/ $(lsb_release -sc) mysql-${MYSQL_VER}" >> /etc/apt/sources.list.d/webstackup.mysql.list
echo "deb-src http://repo.mysql.com/apt/ubuntu/ $(lsb_release -sc) mysql-${MYSQL_VER}" >> /etc/apt/sources.list.d/webstackup.mysql.list
echo "deb http://repo.mysql.com/apt/ubuntu/ $(lsb_release -sc) mysql-tools" >> /etc/apt/sources.list.d/webstackup.mysql.list
  
echo -e "\e[1;45m Generating a random MySQL root password... \e[0m"
MYSQL_ROOT_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password ${MYSQL_ROOT_PASSWORD}"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password ${MYSQL_ROOT_PASSWORD}"
debconf-set-selections <<< "mysql-community-server mysql-server/default-auth-override select"

echo -e "\e[1;45m Installing... \e[0m"
apt update -qq
apt install mysql-server mysql-client -y -qq
  
echo -e "\e[1;45m Enabling the custom config... \e[0m"
cp "${WEBSTACKUP_INSTALL_DIR}config/mysql/mysql.cnf" "/etc/mysql/mysql.conf.d/webstackup.cnf"
sudo chmod u=rw,go=r "/etc/mysql/mysql.conf.d/*.cnf"
  
MYSQL_CREDENTIALS_DIR="/etc/turbolab.it/"
MYSQL_CREDENTIALS_FULLPATH="${MYSQL_CREDENTIALS_DIR}mysql.conf"
  
if [ ! -e "${MYSQL_CREDENTIALS_FULLPATH}" ]; then
  
  echo -e "\e[1;45m Writing MySQL root credentials to ${MYSQL_CREDENTIALS_FULLPATH}... \e[0m"
  mkdir -p "$MYSQL_CREDENTIALS_DIR"
  echo "MYSQL_USER='root'" > "${MYSQL_CREDENTIALS_FULLPATH}"
  echo "MYSQL_PASSWORD='$MYSQL_ROOT_PASSWORD'" >> "${MYSQL_CREDENTIALS_FULLPATH}"
    
  chown root:root "${MYSQL_CREDENTIALS_FULLPATH}"
  chmod u=r,go= "${MYSQL_CREDENTIALS_FULLPATH}"
fi
  
echo -e "\e[1;45m $(cat "${MYSQL_CREDENTIALS_FULLPATH}") \e[0m"
  
service mysql restart
systemctl --no-pager status mysql
