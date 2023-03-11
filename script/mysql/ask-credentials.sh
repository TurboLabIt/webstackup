# Variables
# ---------
# NEW_MYSQL_APP_NAME=my-app
# NEW_MYSQL_USER=my-app_usr
# NEW_MYSQL_USER_FROM_HOST=%
# NEW_MYSQL_PASSWORD=auto
# NEW_MYSQL_HOST=localhost
# NEW_MYSQL_DB_NAME=my-app_db


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


fxTitle "🧔 Username"

## generating a candidate USER_NAME
NEW_MYSQL_USER_DEFAULT=${NEW_MYSQL_APP_NAME}_usr

while [ -z "$NEW_MYSQL_USER" ]; do

  echo "🤖 Provide the MySQL username or hit Enter for ##${NEW_MYSQL_USER_DEFAULT}##"
  read -p ">> " NEW_MYSQL_USER  < /dev/tty
  if [ -z "$NEW_MYSQL_USER" ]; then
    NEW_MYSQL_USER=$NEW_MYSQL_USER_DEFAULT
  fi

done

fxOK "Ack, the MySQL username is ##$NEW_MYSQL_USER##"


fxTitle "🗺 ${NEW_MYSQL_USER}@...."

## generating a candidate host
if [ "${NEW_MYSQL_USER}" == "root" ]; then
  NEW_MYSQL_DEFAULT_USER_FROM_HOST=localhost
else
  NEW_MYSQL_DEFAULT_USER_FROM_HOST='%'
fi

while [ -z "$NEW_MYSQL_USER_FROM_HOST" ]; do

  echo "🤖 Enter the origin host (where the user will be connecting ⭐⭐FROM⭐⭐)"
  echo "It will be used to create the user as ##${NEW_MYSQL_USER}##@xxxxx"
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


fxTitle "🔑 Password"

## generating a candidate password
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


fxTitle "🎯 MySQL host"
while [ -z "$NEW_MYSQL_HOST" ]; do

  echo "🤖 Provide the server hostname/IP address or hit Enter for ##localhost##"
  read -p ">> " NEW_MYSQL_HOST  < /dev/tty
  if [ -z "$NEW_MYSQL_HOST" ]; then
    NEW_MYSQL_HOST="localhost"
  fi
  
done

fxOK "MySQL host: ##$NEW_MYSQL_HOST##"


fxTitle "🧺 Database name"

## generating a candidate DBNAME
NEW_MYSQL_DB_NAME_DEFAULT=${NEW_MYSQL_APP_NAME}_db

while [ -z "$NEW_MYSQL_DB_NAME" ]; do

  echo "🤖 Provide the database name or hit Enter for ##${NEW_MYSQL_DB_NAME_DEFAULT}##"
  read -p ">> " NEW_MYSQL_DB_NAME  < /dev/tty
  if [ -z "$NEW_MYSQL_DB_NAME" ]; then
    NEW_MYSQL_DB_NAME=$NEW_MYSQL_DB_NAME_DEFAULT
  fi

done

fxOK "Sounds good! The database will be named ##$NEW_MYSQL_DB_NAME##"


fxTitle "🚀 Preview..."
fxMessage "AppName:       ##$NEW_MYSQL_APP_NAME##"
fxMessage "User:          ##$NEW_MYSQL_USER##@##${NEW_MYSQL_USER_FROM_HOST}##"
fxMessage "Password:      ##$NEW_MYSQL_PASSWORD##"
fxMessage "MySQL server:  ##$NEW_MYSQL_HOST##"
fxMessage "DB Name:       ##$NEW_MYSQL_DB_NAME##"
fxCountdown 5
echo ""


fxTitle "📦 Installing prerequisites..."
if [ -z "$(command -v mysql)" ]; then
  apt update && apt install mysql-client -y
else
  fxInfo "prerequisite(s) already installed"
fi
