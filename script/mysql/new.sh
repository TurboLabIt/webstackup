#!/usr/bin/env bash
### GUIDED MySQL USER CREATION BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/new.sh

source "/usr/local/turbolab.it/webstackup/script/base.sh"

fxHeader "🗄️ ‍MySQL new database access"
rootCheck

MYSQL_CREDENTIALS_FILE=/etc/turbolab.it/mysql.conf
if [ ! -e "${MYSQL_CREDENTIALS_FILE}" ]; then
  fxCatastrophicError "Credentials file ${MYSQL_CREDENTIALS_FILE} not found!"
fi


source "${WEBSTACKUP_SCRIPT_DIR}mysql/ask-credentials.sh"


fxTitle "🧺 Database name"
while [ -z "$NEW_MYSQL_DB_NAME" ]; do

  echo "🤖 Provide the database name or hit Enter for ##${NEW_MYSQL_DB_NAME_DEFAULT}##"
  read -p ">> " NEW_MYSQL_DB_NAME  < /dev/tty
  if [ -z "$NEW_MYSQL_DB_NAME" ]; then
    NEW_MYSQL_DB_NAME=$NEW_MYSQL_DB_NAME_DEFAULT
  fi

done

fxOK "Swell, the database will be named ##$NEW_MYSQL_USER##"


fxTitle "🚀 Preview..."
fxMessage "AppName:     ##$NEW_MYSQL_APP_NAME##"
fxMessage "User:        ##$NEW_MYSQL_USER##"
fxMessage "Password:    ##$NEW_MYSQL_PASSWORD##"
fxMessage "Host:        ##$NEW_MYSQL_HOST##"
fxMessage "DB Name:     ##$NEW_MYSQL_DB_NAME##"
fxCountdown 5
echo ""



fxTitle "📦 Installing prerequisites..."
if [ -z "$(command -v mysql)" ]; then
  apt update && apt install mysql-client -y
else
  fxInfo "prerequisite(s) already installed"
fi


fxTitle "🧔 Creating the user..."  
wsuMysql -e "CREATE USER '$NEW_MYSQL_USER'@'%' IDENTIFIED BY '$NEW_MYSQL_PASSWORD';"

fxTitle "🧺 Creating the database..."
wsuMysql -e "CREATE DATABASE \`$NEW_MYSQL_DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"

fxTitle "🔑 Granting privileges..."
wsuMysql -e "GRANT ALL PRIVILEGES ON \`${NEW_MYSQL_DB_NAME//_/\\_}%\`.* TO '$NEW_MYSQL_USER'@'%';"
wsuMysql -e "GRANT RELOAD, PROCESS ON *.* TO '$NEW_MYSQL_USER'@'%';"
wsuMysql -e "FLUSH PRIVILEGES;"

wsuMysqlStoreCredentials "${NEW_MYSQL_APP_NAME}" "${NEW_MYSQL_USER}" "${NEW_MYSQL_PASSWORD}" "${MYSQL_HOST}" "${NEW_MYSQL_DB_NAME}"

fxEndFooter
