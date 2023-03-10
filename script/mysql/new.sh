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

NEW_MYSQL_APP_NAME=$1
NEW_MYSQL_USER=$1
NEW_MYSQL_PASSWORD=$2
NEW_MYSQL_DB_NAME=$3


fxTitle "🖥️ APP_NAME"
fxInfo "For example: \"turbolab_it\" or \"my-amazing-shop\""
fxWarning "Lowercase letters [a-z] and numbers [0-9] only!"
while [ -z "$NEW_MYSQL_APP_NAME" ]; do

  echo "🤖 Provide the APP_NAME"
  read -p ">> " NEW_MYSQL_APP_NAME  < /dev/tty

done

NEW_MYSQL_APP_NAME=$(echo "$NEW_MYSQL_APP_NAME" | tr '[:upper:]' '[:lower:]')
NEW_MYSQL_APP_NAME=${NEW_MYSQL_APP_NAME// /-}

fxOK "Got it, APP_NAME is ##$NEW_MYSQL_APP_NAME##"


## auto-generating a candidate USER_NAME and DB_NAME
NEW_MYSQL_USER_DEFAULT=${NEW_MYSQL_APP_NAME}_usr
NEW_MYSQL_DB_NAME_DEFAULT=${NEW_MYSQL_APP_NAME}_db


fxTitle "🧔 Username"
while [ -z "$NEW_MYSQL_USER" ]; do

  echo "🤖 Provide the new MySQL username or hit Enter for ##${NEW_MYSQL_USER_DEFAULT}##"
  read -p ">> " NEW_MYSQL_USER  < /dev/tty
  if [ -z "$NEW_MYSQL_USER" ]; then
    NEW_MYSQL_USER=$NEW_MYSQL_USER_DEFAULT
  fi

done

fxOK "Ack, the new MySQL username is ##$NEW_MYSQL_USER##"


fxTitle "🔑 Password"
if [ "$NEW_MYSQL_PASSWORD" = "auto" ]; then
  NEW_MYSQL_PASSWORD="$(fxPasswordGenerator)"
fi

while [ -z "$NEW_MYSQL_PASSWORD" ]; do

  echo "🤖 Provide the password (leave blank for autogeneration)"
  read -p ">> " NEW_MYSQL_PASSWORD  < /dev/tty

  if [ -z "$NEW_MYSQL_PASSWORD" ]; then
    NEW_MYSQL_PASSWORD="$(fxPasswordGenerator)"
  fi
  
done

fxOK "OK, $NEW_MYSQL_PASSWORD"


fxTitle "🧺 Database name"
while [ -z "$NEW_MYSQL_DB_NAME" ]; do

  echo "🤖 Provide the new database name or hit Enter for ##${NEW_MYSQL_DB_NAME_DEFAULT}##"
  read -p ">> " NEW_MYSQL_DB_NAME  < /dev/tty
  if [ -z "$NEW_MYSQL_DB_NAME" ]; then
    NEW_MYSQL_DB_NAME=$NEW_MYSQL_DB_NAME_DEFAULT
  fi

done

fxOK "Swell, the new database will be named ##$NEW_MYSQL_USER##"


fxTitle "🚀 Preview..."
fxMessage "AppName:     ##$NEW_MYSQL_APP_NAME##"
fxMessage "User:        ##$NEW_MYSQL_USER##"
fxMessage "Password:    ##$NEW_MYSQL_PASSWORD##"
fxMessage "DB Name:     ##$NEW_MYSQL_DB_NAME##"
fxCountdown ${WSU_MAP_PRE_EXEC_PAUSE_SEC}
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
