#!/usr/bin/env bash
### GUIDED MySQL PASSWORD RESET BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/password-reset.sh
#

echo ""
echo -e "\e[1;46m ============================ \e[0m"
echo -e "\e[1;46m 🗄️ MYSQL PASSWORD RESET      \e[0m"
echo -e "\e[1;46m ============================ \e[0m"

if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi

source "/usr/local/turbolab.it/webstackup/script/base.sh"

NEW_MYSQL_USER=$1
NEW_MYSQL_PASSWORD=$2
NEW_MYSQL_DB_NAME=$3

if [ -z $NEW_MYSQL_USER ] || [ -z $NEW_MYSQL_PASSWORD ] || [ -z $NEW_MYSQL_DB_NAME ]; then
  NEW_MYSQL_USER=
  NEW_MYSQL_PASSWORD=
  NEW_MYSQL_DB_NAME=
fi


printTitle "🧔 Username"
while [ -z "$NEW_MYSQL_USER" ]
do
  read -p "🤖 Provide the username: " NEW_MYSQL_USER  < /dev/tty
done


printTitle "🔑 Password"
while [ -z "$NEW_MYSQL_PASSWORD" ]
do
  read -p "🤖 Provide the password (leave blank for autogeneration): " NEW_MYSQL_PASSWORD  < /dev/tty
  
  if [ -z "$NEW_MYSQL_PASSWORD" ]; then
    NEW_MYSQL_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
  fi
  
done

fxTitle "Attempting to stop Nginx..."
service nginx stop

fxTitle "Stopping MySQL..."
service mysql stop

fxTitle "Starting MySQL as application..."
# mkdir -p /var/run/mysqld
# chown mysql:mysql /var/run/mysqld
/usr/sbin/mysqld --skip-grant-tables --skip-networking &

fxTitle "Setting the password..."
wsuMysql -e "SET PASSWORD FOR ${NEW_MYSQL_USER}@'localhost' = PASSWORD('${NEW_MYSQL_PASSWORD}');"
wsuMysql -e "FLUSH PRIVILEGES;"

fxTitle "Stopping MySQL as application..."
pkill mysqld

fxTitle "Starting MySQL..."
service mysql start

fxTitle "Attempting to restart Nginx..."
service nginx start

wsuMysqlStoreCredentials "$NEW_MYSQL_USER" "$NEW_MYSQL_PASSWORD" "$MYSQL_HOST" "/etc/turbolab.it/mysql.conf"

fxEndFooter
