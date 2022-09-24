#!/usr/bin/env bash
### GUIDED MySQL PASSWORD RESET BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/password-reset.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/password-reset.sh?$(date +%s) | sudo bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🤦‍MySQL password reset"
rootCheck
echo "Manine dimenticose edition"
echo ""

source "/usr/local/turbolab.it/webstackup/script/base.sh"

TARGET_MYSQL_USER=$1
TARGET_MYSQL_PASSWORD=$2
TARGET_MYSQL_USER_HOST=$3

fxTitle "🧔 Username"
while [ -z "$TARGET_MYSQL_USER" ]
do
  read -p "🤖 Provide the username: " TARGET_MYSQL_USER  < /dev/tty
done

fxTitle "🔑 Password"
while [ -z "$TARGET_MYSQL_PASSWORD" ]
do
  read -p "🤖 Provide the password (leave blank for autogeneration): " TARGET_MYSQL_PASSWORD  < /dev/tty

  if [ -z "$TARGET_MYSQL_PASSWORD" ]; then
    TARGET_MYSQL_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
  fi
done

fxTitle "${TARGET_MYSQL_USER}@ host"
while [ -z "$TARGET_MYSQL_USER_HOST" ]
do
  read -p "🤖 Provide the host (leave blank for localhost): " TARGET_MYSQL_USER_HOST  < /dev/tty

  if [ -z "$TARGET_MYSQL_USER_HOST" ]; then
    TARGET_MYSQL_USER_HOST="localhost"
  fi
done

fxTitle "New credentials preview"
echo "User:  ##${TARGET_MYSQL_USER}##@##${TARGET_MYSQL_USER_HOST}##"
echo "Pass:  ##${TARGET_MYSQL_PASSWORD}##"

fxTitle "Creating MySQL init file..."
MYSQL_PASSWD_RESET_FILE=/tmp/mysql_password_reset.sql
echo -n \
  "ALTER USER '${TARGET_MYSQL_USER}'@'${TARGET_MYSQL_USER_HOST}' IDENTIFIED WITH mysql_native_password BY '${TARGET_MYSQL_PASSWORD}';" \
  >> "${MYSQL_PASSWD_RESET_FILE}"

fxMessage "$(cat ${MYSQL_PASSWD_RESET_FILE})"

fxTitle "Securing the init file..."
chown mysql:root "${MYSQL_PASSWD_RESET_FILE}"
chmod u=r,go= "${MYSQL_PASSWD_RESET_FILE}"
ls -l "${MYSQL_PASSWD_RESET_FILE}"

fxTitle "Attempting to stop Nginx..."
service nginx stop

fxTitle "Stopping MySQL..."
service mysql stop

fxTitle "Starting MySQL as application..."
# mkdir -p /var/run/mysqld
# chown mysql:mysql /var/run/mysqld
sudo -u mysql -H mysqld --skip-networking --init-file="${MYSQL_PASSWD_RESET_FILE}" &

fxTitle "Removing the init file..."
rm -f "${MYSQL_PASSWD_RESET_FILE}"

fxTitle "Display MySQL error log..."
fxMessage "$(tail -n 50 /var/log/mysql/error.log)"

fxTitle "Stopping MySQL as application..."
pkill mysqld

fxTitle "Starting MySQL..."
service mysql start

fxTitle "Attempting to restart Nginx..."
service nginx start

wsuMysqlStoreCredentials "$TARGET_MYSQL_USER" "$TARGET_MYSQL_PASSWORD"

fxEndFooter
