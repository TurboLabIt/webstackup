#!/usr/bin/env bash
### GUIDED MySQL USER CREATION BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/new.sh

source "/usr/local/turbolab.it/webstackup/script/base.sh"

fxHeader "🗄️ ‍MySQL new database access"
rootCheck

MYSQL_CREDENTIALS_FILE=/etc/turbolab.it/mysql.conf
if [ ! -e "${MYSQL_CREDENTIALS_FILE}" ]; then
  fxCatastrophicError "Credentials file ${MYSQL_CREDENTIALS_FILE} not found!"
fi

source "${WEBSTACKUP_SCRIPT_DIR}mysql/ask-credentials.sh"

fxTitle "🧔 Creating the user..."  
wsuMysql -e "CREATE USER '$NEW_MYSQL_USER'@'$NEW_MYSQL_USER_FROM_HOST' IDENTIFIED BY '$NEW_MYSQL_PASSWORD';"

fxTitle "🧺 Creating the database..."
wsuMysql -e "CREATE DATABASE \`$NEW_MYSQL_DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"

fxTitle "🔑 Granting privileges..."
wsuMysql -e "GRANT ALL PRIVILEGES ON \`${NEW_MYSQL_APP_NAME//_/\\_}%\`.* TO '$NEW_MYSQL_USER'@'$NEW_MYSQL_USER_FROM_HOST';"
wsuMysql -e "GRANT ALL PRIVILEGES ON \`${NEW_MYSQL_DB_NAME}\`.* TO '$NEW_MYSQL_USER'@'$NEW_MYSQL_USER_FROM_HOST';"
wsuMysql -e "GRANT RELOAD, PROCESS ON *.* TO '$NEW_MYSQL_USER'@'$NEW_MYSQL_USER_FROM_HOST';"
wsuMysql -e "FLUSH PRIVILEGES;"

wsuMysqlStoreCredentials "${NEW_MYSQL_APP_NAME}" "${NEW_MYSQL_USER}" "${NEW_MYSQL_PASSWORD}" "${MYSQL_HOST}" "${NEW_MYSQL_DB_NAME}"

fxEndFooter
