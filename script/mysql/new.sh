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


NEW_MYSQL_USER=$1
NEW_MYSQL_PASSWORD=$2
NEW_MYSQL_DB_NAME=$3


fxTitle "🧔 Username"
while [ -z "$NEW_MYSQL_USER" ]
do
  read -p "🤖 Provide the username: " NEW_MYSQL_USER  < /dev/tty
done

fxOK "OK, $NEW_MYSQL_USER"


fxTitle "🔑 Password"
while [ -z "$NEW_MYSQL_PASSWORD" ]
do
  read -p "🤖 Provide the password (leave blank for autogeneration): " NEW_MYSQL_PASSWORD  < /dev/tty
  if [ -z "$NEW_MYSQL_PASSWORD" ]; then
    NEW_MYSQL_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
  fi
done

fxOK "OK, $NEW_MYSQL_PASSWORD"


fxTitle "🧺 DB name"
while [ -z "$NEW_MYSQL_DB_NAME" ]
do
  read -p "🤖 Provide the name of the database to create (leave blank if same as username): " NEW_MYSQL_DB_NAME  < /dev/tty
  if [ -z "$NEW_MYSQL_DB_NAME" ]; then
    NEW_MYSQL_DB_NAME=$NEW_MYSQL_USER
  fi
done

fxOK "OK, $NEW_MYSQL_DB_NAME"


fxTitle "Preview"
echo "User:  ##${NEW_MYSQL_USER}##@%"
echo "Pass:  ##${NEW_MYSQL_PASSWORD}##"
echo "DB:    ##${NEW_MYSQL_DB_NAME}##"


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
wsuMysql -e "FLUSH PRIVILEGES;"

wsuMysqlStoreCredentials "$NEW_MYSQL_USER" "$NEW_MYSQL_PASSWORD" "$MYSQL_HOST" "$NEW_MYSQL_DB_NAME"

fxEndFooter
