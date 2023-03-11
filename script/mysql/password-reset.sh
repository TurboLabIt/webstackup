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

## this script can run only on the same host as MySQL
NEW_MYSQL_HOST=localhost


WSU_BASE="/usr/local/turbolab.it/webstackup/script/base.sh"
if [ -f "${WSU_BASE}" ]; then

  source "$WSU_BASE"
  source "${WEBSTACKUP_SCRIPT_DIR}mysql/ask-credentials.sh"

else

  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/ask-credentials.sh)
fi


fxTitle "📜 Creating the MySQL init file..."
MYSQL_PASSWD_RESET_FILE=/tmp/mysql_password_reset.sql
rm -f "${MYSQL_PASSWD_RESET_FILE}"
touch "$MYSQL_PASSWD_RESET_FILE"
fxOK "MySQL init file ##$MYSQL_PASSWD_RESET_FILE## created"


fxTitle "👮‍♂️ Changing file permissions..."
chown root:root "${MYSQL_PASSWD_RESET_FILE}"
chmod u=rwx,go= "${MYSQL_PASSWD_RESET_FILE}"


fxTitle "📜 Adding content to the MySQL init file..."
echo \
  "ALTER USER '${NEW_MYSQL_USER}'@'${NEW_MYSQL_USER_FROM_HOST}' IDENTIFIED BY '${NEW_MYSQL_PASSWORD}';" \
  > "${MYSQL_PASSWD_RESET_FILE}"

fxMessage "$(cat ${MYSQL_PASSWD_RESET_FILE})"


fxTitle "🌐 Stopping nginx..."
systemctl is-active --quiet nginx
if [ "$?" = "0" ]; then
  NGINX_RESTART_NEEDED=1
  service nginx stop
else
  fxInfo "nginx not detected"
fi


fxTitle "🗄 Stopping MySQL..."
service mysql stop


fxTitle "👮‍♂️ Changing file permissions..."
chown mysql:root "${MYSQL_PASSWD_RESET_FILE}"
chmod u=rwx,go= "${MYSQL_PASSWD_RESET_FILE}"


fxTitle "🎡 Starting MySQL as application..."
sudo -u mysql -H mysqld --skip-networking --init-file="${MYSQL_PASSWD_RESET_FILE}" &
fxCountdown 15


fxTitle "🧹 Removing the MySQL init file..."
rm -f "${MYSQL_PASSWD_RESET_FILE}"


fxTitle "👓 Display MySQL error log..."
tail -n 10 /var/log/mysql/error.log


fxTitle "🗄 Stopping MySQL as application..."
while pkill mysqld; do
  echo "Waiting for MySQL to stop..."
  fxCountdown 15
done


fxTitle "✳ Starting MySQL..."
service mysql start


fxTitle "🌐 Restarting nginx..."
if [ ! -z "$NGINX_RESTART_NEEDED" ]; then
  service nginx restart
else
  fxInfo "nginx not detected"
fi


if [ -f "${WSU_BASE}" ]; then

  wsuMysqlStoreCredentials "$NEW_MYSQL_APP_NAME" "$NEW_MYSQL_USER" "$NEW_MYSQL_PASSWORD" "$NEW_MYSQL_HOST" "$NEW_MYSQL_DB_NAME"

else

  fxTitle "🧪 Testing..."
  mysql -u${NEW_MYSQL_USER} -p"${NEW_MYSQL_PASSWORD}" -h localhost -e "SHOW DATABASES;"
fi

fxEndFooter
