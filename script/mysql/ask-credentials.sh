NEW_MYSQL_APP_NAME=$1
NEW_MYSQL_USER=$1
NEW_MYSQL_PASSWORD=$2
NEW_MYSQL_DB_NAME=$3
NEW_MYSQL_HOST=$4
NEW_MYSQL_USER_FROM_HOST=$5


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

  echo "🤖 Provide the MySQL username or hit Enter for ##${NEW_MYSQL_USER_DEFAULT}##"
  read -p ">> " NEW_MYSQL_USER  < /dev/tty
  if [ -z "$NEW_MYSQL_USER" ]; then
    NEW_MYSQL_USER=$NEW_MYSQL_USER_DEFAULT
  fi

done

fxOK "Ack, the MySQL username is ##$NEW_MYSQL_USER##"


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


fxTitle "🎯 MySQL server host"
while [ -z "$NEW_MYSQL_HOST" ]; do

  echo "🤖 Provide the host where MySQL is running or hit Enter for localhost"
  read -p ">> " NEW_MYSQL_HOST  < /dev/tty
  if [ -z "$NEW_MYSQL_HOST" ]; then
    NEW_MYSQL_HOST="localhost"
  fi
  
done

fxOK "Database host: $NEW_MYSQL_HOST"


if [ "${NEW_MYSQL_USER}" == "" ]; then
  NEW_MYSQL_DEFAULT_USER_FROM_HOST=localhost
else
  NEW_MYSQL_DEFAULT_USER_FROM_HOST='%'
fi


fxTitle "🗺 ${NEW_MYSQL_USER}@????"
while [ -z "$NEW_MYSQL_USER_FROM_HOST" ]; do

  echo "🤖 Enter the origin host (where this user will be connecting ⭐⭐FROM⭐⭐)"
  echo "This will be used to create the user as ##${NEW_MYSQL_USER}@....##"
  echo ""
  echo "Examples:"
  echo "- % (every host)"
  echo "- localhost"
  echo "- 172.10.15.20"
  echo ""
  echo "Hit Enter for ##${NEW_MYSQL_DEFAULT_USER_FROM_HOST}##"
  read -p ">> " NEW_MYSQL_USER_FROM_HOST  < /dev/tty
  if [ -z "$NEW_MYSQL_USER_FROM_HOST" ]; then
    NEW_MYSQL_USER_FROM_HOST=$NEW_MYSQL_DEFAULT_USER_FROM_HOST
  fi

done

fxOK "OK, ##$NEW_MYSQL_USER_FROM_HOST##"


fxTitle "🧺 Database name"
while [ -z "$NEW_MYSQL_DB_NAME" ]; do

  echo "🤖 Provide the database name or hit Enter for ##${NEW_MYSQL_DB_NAME_DEFAULT}##"
  read -p ">> " NEW_MYSQL_DB_NAME  < /dev/tty
  if [ -z "$NEW_MYSQL_DB_NAME" ]; then
    NEW_MYSQL_DB_NAME=$NEW_MYSQL_DB_NAME_DEFAULT
  fi

done

fxOK "Sounds good! The database will be named ##$NEW_MYSQL_USER##"


fxTitle "🚀 Preview..."
fxMessage "AppName:       ##$NEW_MYSQL_APP_NAME##"
fxMessage "User:          ##$NEW_MYSQL_USER##@##${NEW_MYSQL_USER_FROM_HOST}##"
fxMessage "Password:      ##$NEW_MYSQL_PASSWORD##"
fxMessage "MySQL server:  ##$NEW_MYSQL_HOST##"
fxMessage "DB Name:       ##$NEW_MYSQL_DB_NAME##"
fxCountdown 5
echo ""
