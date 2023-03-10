NEW_MYSQL_APP_NAME=$1
NEW_MYSQL_USER=$1
NEW_MYSQL_PASSWORD=$2
NEW_MYSQL_DB_NAME=$3
NEW_MYSQL_HOST=$4


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


fxTitle "🎯 Host"
while [ -z "$NEW_MYSQL_HOST" ]; do

  echo "🤖 Provide the host or hit Enter for localhost"
  read -p ">> " NEW_MYSQL_HOST  < /dev/tty
  if [ -z "$NEW_MYSQL_HOST" ]; then
    NEW_MYSQL_HOST="localhost"
  fi
  
done

fxOK "Database host: $NEW_MYSQL_HOST"
