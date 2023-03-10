#!/usr/bin/env bash
### READY-TO-RUN, FULLY CUSTOMIZED MYSQL COMMANDS BY WEBSTACK.UP


function wsuMysqlReadConfig()
{
  if [ -r "/etc/turbolab.it/mysql.conf" ]; then
    MYSQL_HOST=127.0.0.1
    source "/etc/turbolab.it/mysql.conf"
  fi
}

wsuMysqlReadConfig


function wsuMysql()
{
  fxTitle "🗄️ wsuMysql"
  
  if [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_HOST}" ]; then
  
    if [ -r "/etc/turbolab.it/mysql.conf" ]; then
    
       wsuMysqlReadConfig
      
    elif [ ! -r "/etc/turbolab.it/mysql.conf" ] && [ -f "/etc/turbolab.it/mysql.conf" ]; then
    
      sudo cp -a "/etc/turbolab.it/mysql.conf" "/etc/turbolab.it/mysql_wsuMysql_temp.conf"
      sudo chmod ugo+r "/etc/turbolab.it/mysql.conf"
      
      wsuMysqlReadConfig
      
      sudo rm -f "/etc/turbolab.it/mysql.conf"
      sudo mv "/etc/turbolab.it/mysql_wsuMysql_temp.conf" "/etc/turbolab.it/mysql.conf"

    fi

  fi

  if [ ! -z "$MYSQL_PASSWORD" ]; then
    MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
  fi
  
  echo "👤 User:    ##${MYSQL_USER}##"
  echo "🔑 Pass:    ##${MYSQL_PASSWORD_HIDDEN}##"
  echo "🖥️ Host:    ##${MYSQL_HOST}##"
  echo "🔨 Command: ##$@##"

  if [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_HOST}" ]; then
    fxCatastrophicError "wsuMysql error. Some required parameters are empty"
  fi

  mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" "$@"
}


function wsuMysqlStoreCredentials()
{
  local MYSQL_APP_NAME=$1
  local MYSQL_USER=$2
  local MYSQL_INPUT_PASSWORD=$3
  local MYSQL_INPUT_HOST=$4
  local MYSQL_INPUT_DB_NAME=$5
  
  if [ "${MYSQL_USER}" = "root" ]; then
    local FILENAME=/etc/turbolab.it/mysql.conf
  else
    local FILENAME=/etc/turbolab.it/mysql-${MYSQL_APP_NAME}.conf
  fi
  
  if [ -e "${FILENAME}" ]; then
    source "${FILENAME}"
  fi
  
  if [ ! -z "${MYSQL_INPUT_PASSWORD}" ]; then
    MYSQL_PASSWORD=${MYSQL_INPUT_PASSWORD}
  fi
  
  if [ ! -z "${MYSQL_INPUT_HOST}" ]; then
    MYSQL_HOST=${MYSQL_INPUT_HOST}
  fi

  if [ ! -z "${MYSQL_INPUT_DB_NAME}" ]; then
    MYSQL_DB_NAME=${MYSQL_INPUT_DB_NAME}
  fi


  fxTitle "💾 Storing MySQL credentials to ${FILENAME}..."
  echo "MYSQL_USER=$MYSQL_USER" > "$FILENAME"
  echo "MYSQL_PASSWORD='$MYSQL_PASSWORD'" >> "$FILENAME"
  echo "MYSQL_HOST=$MYSQL_HOST" >> "$FILENAME"
  
  if [ "$FILENAME" != "/etc/turbolab.it/mysql.conf" ] && [ ! -z "MYSQL_DB_NAME" ]; then
    echo "MYSQL_DB_NAME=$MYSQL_DB_NAME" >> "$FILENAME"
  fi
  
  fxOK "ℹ Credentials saved to $FILENAME"
  
  if [ "$FILENAME" = "/etc/turbolab.it/mysql.conf" ]; then
  
    fxTitle "🔒 Restricting access to root only..."
    chown root:root "$FILENAME"
    chmod u=rw,go= "$FILENAME"
  fi
  
  fxTitle "🧪 Testing..."
  mysql -u${MYSQL_USER} -p"${MYSQL_PASSWORD}" -h ${MYSQL_HOST} -e "SHOW DATABASES;"
}
