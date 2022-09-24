#!/usr/bin/env bash
### GUIDED MySQL PASSWORD RESET BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/password-reset.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/password-reset.sh?$(date +%s) | sudo bash
#
# Based on: https://turbolab.it/3354 | https://dev.mysql.com/doc/refman/8.0/en/resetting-permissions.html

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🤦‍MySQL password reset"
rootCheck

WSU_BASE="/usr/local/turbolab.it/webstackup/script/base.sh"
if [ -f "${WSU_BASE}" ]; then
  source "$WSU_BASE"
fi


TARGET_MYSQL_USER=$1
TARGET_MYSQL_PASSWORD=$2
TARGET_MYSQL_USER_HOST=$3


fxTitle "🧔 Username"
while [ -z "$TARGET_MYSQL_USER" ]
do
  read -p "🤖 Provide the username (leave blank for root): " TARGET_MYSQL_USER  < /dev/tty
  if [ -z "$TARGET_MYSQL_USER" ]; then
    TARGET_MYSQL_USER=root
  fi
done

fxOK "OK, $TARGET_MYSQL_USER"


fxTitle "🔑 Password"
while [ -z "$TARGET_MYSQL_PASSWORD" ]
do
  read -p "🤖 Provide the password (leave blank for autogeneration): " TARGET_MYSQL_PASSWORD  < /dev/tty
  if [ -z "$TARGET_MYSQL_PASSWORD" ]; then
    TARGET_MYSQL_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
  fi
done

fxOK "OK, $TARGET_MYSQL_PASSWORD"


fxTitle "${TARGET_MYSQL_USER}@ host"
while [ -z "$TARGET_MYSQL_USER_HOST" ]
do
  read -p "🤖 Provide the host (leave blank for @localhost): " TARGET_MYSQL_USER_HOST  < /dev/tty
  if [ -z "$TARGET_MYSQL_USER_HOST" ]; then
    TARGET_MYSQL_USER_HOST=localhost
  fi
done

fxOK "OK, $TARGET_MYSQL_USER_HOST"


fxTitle "Preview"
echo "User:  ##${TARGET_MYSQL_USER}##@##${TARGET_MYSQL_USER_HOST}##"
echo "Pass:  ##${TARGET_MYSQL_PASSWORD}##"


fxTitle "Creating MySQL init file..."
MYSQL_PASSWD_RESET_FILE=/tmp/mysql_password_reset.sql
rm -f "${MYSQL_PASSWD_RESET_FILE}"
echo \
  "ALTER USER '${TARGET_MYSQL_USER}'@'${TARGET_MYSQL_USER_HOST}' IDENTIFIED BY '${TARGET_MYSQL_PASSWORD}';" \
  > "${MYSQL_PASSWD_RESET_FILE}"

fxMessage "$(cat ${MYSQL_PASSWD_RESET_FILE})"


fxTitle "Securing the init file..."
chown mysql:root "${MYSQL_PASSWD_RESET_FILE}"
chmod ug=rw,o= "${MYSQL_PASSWD_RESET_FILE}"
ls -l "${MYSQL_PASSWD_RESET_FILE}"


fxTitle "Stopping nginx..."
systemctl is-active --quiet nginx
if [ "$?" = "0" ]; then
  NGINX_RESTART_NEEDED=1
  service nginx stop
else
  fxInfo "nginx not detected"
fi


fxTitle "Stopping MySQL..."
service mysql stop


fxTitle "Starting MySQL as application..."
sudo -u mysql -H mysqld --skip-networking --init-file="${MYSQL_PASSWD_RESET_FILE}" &
sleep 15


fxTitle "Removing the init file..."
rm -f "${MYSQL_PASSWD_RESET_FILE}"


fxTitle "Display MySQL error log..."
tail -n 10 /var/log/mysql/error.log


fxTitle "Stopping MySQL as application..."
while pkill mysqld; do
  echo "Waiting..."
  sleep 15
done


fxTitle "Starting MySQL..."
service mysql start


fxTitle "Restarting nginx..."
if [ ! -z "$NGINX_RESTART_NEEDED" ]; then
  service nginx restart
else
  fxInfo "nginx not detected"
fi


if [ -f "${WSU_BASE}" ]; then
  wsuMysqlStoreCredentials "$TARGET_MYSQL_USER" "$TARGET_MYSQL_PASSWORD"
else
  fxTitle "🧪 Testing..."
  mysql -u${MYSQL_USER} -p"${MYSQL_PASS}" -h localhost -e "SHOW DATABASES;"
fi

fxEndFooter
