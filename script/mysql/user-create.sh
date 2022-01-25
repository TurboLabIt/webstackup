#!/usr/bin/env bash
### GUIDED MySQL USER CREATION BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/user-create.sh
echo ""

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "🚀 Create a new MySQL user"
rootCheck


MYSQL_CREDENTIALS_FILE=/etc/turbolab.it/mysql.conf
if [ -f ${MYSQL_CREDENTIALS_FILE} ]; then
  catastrophicError "Credentials file ${MYSQL_CREDENTIALS_FILE} not found!"
  exit;
fi


NEW_MYSQL_USER=$1
NEW_MYSQL_PASSWORD=$2
NEW_MYSQL_HOST=$3
NEW_MYSQL_DB_NAME=$4

if [ -z $NEW_MYSQL_USER ] || [ -z $NEW_MYSQL_PASSWORD ] || [ -z $NEW_MYSQL_HOST ] || [ -z $NEW_MYSQL_DB_NAME ]; then
  catastrophicError "Bad command line! Arguments are: user password host db_name"
  exit;
fi


if [ -z "$(command -v git)" ]; then

  printTitle "📦 Installing prerequisites..."
  apt update && apt install mysql-client -y
  
fi

source $MYSQL_CREDENTIALS_FILE
MYSQL_EXE="mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${MYSQL_HOST}"


printMessage "🧔 Creating user..."  
$MYSQL_EXE -e "CREATE USER '$NEW_MYSQL_USER'@'%' IDENTIFIED BY '$NEW_MYSQL_PASSWORD';"

printMessage "🧺 Creating database..."
$MYSQL_EXE -e "CREATE DATABASE \`$NEW_MYSQL_DB_NAME\`;"

printMessage 🔑 Granting privileges..."
$MYSQL_EXE -e "GRANT ALL PRIVILEGES ON \`${NEW_MYSQL_DB_NAME//_/\\_}%\`.* TO '$NEW_MYSQL_USER'@'%';"
$MYSQL_EXE -e "FLUSH PRIVILEGES;"


printMessage "💾 Saving credentials..."
MYSQL_NEW_CREDENTIALS_STORE_FILE=${WEBSTACKUP_AUTOGENERATED_DIR}${NEW_MYSQL_USER}.mysql.conf
echo "MYSQL_USER=$NEW_MYSQL_USER" > "${MYSQL_NEW_CREDENTIALS_STORE_FILE}"
echo "MYSQL_PASSWORD=$NEW_MYSQL_PASSWORD" >> "${MYSQL_NEW_CREDENTIALS_STORE_FILE}"
echo "MYSQL_HOST=$MYSQL_HOST" >> "${MYSQL_NEW_CREDENTIALS_STORE_FILE}"
echo "NEW_MYSQL_DB=$NEW_MYSQL_DB_NAME" >> "${MYSQL_NEW_CREDENTIALS_STORE_FILE}"

printMessage "🔒 Restricting access to root only..."
chown root:root "${MYSQL_NEW_CREDENTIALS_STORE_FILE}"
chmod u=r,go= "${MYSQL_NEW_CREDENTIALS_STORE_FILE}"

printMessage "ℹ Credentials saved in $MYSQL_NEW_CREDENTIALS_STORE_FILE"
printMessage "$(cat "${MYSQL_NEW_CREDENTIALS_STORE_FILE}")"

printTheEnd
