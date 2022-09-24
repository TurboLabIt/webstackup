#!/usr/bin/env bash
### READY-TO-RUN, FULLY CUSTOMIZED MYSQL COMMANDS BY WEBSTACK.UP

if [ -r "/etc/turbolab.it/mysql.conf" ]; then
  MYSQL_HOST=127.0.0.1
  source "/etc/turbolab.it/mysql.conf"
fi


function wsuMysql()
{
  mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" "$@"
}


function wsuMysqlStoreCredentials()
{
  local MYSQL_USER=$1
  local MYSQL_INPUT_PASS=$2
  local MYSQL_INPUT_HOST=$3
  local MYSQL_INPUT_DB_NAME=$4
  
  if [ "${MYSQL_USER}" = "root" ]; then
    local FILENAME=/etc/turbolab.it/mysql.conf
  else
    local FILENAME=/etc/turbolab.it/mysql-${MYSQL_USER}.conf
  fi
  
  if [ -e "${FILENAME}" ]; then
    source "${FILENAME}"
  fi
  
  if [ ! -z "${MYSQL_INPUT_PASS}" ]; then
    MYSQL_PASS=${MYSQL_INPUT_PASS}
  fi
  
  if [ ! -z "${MYSQL_INPUT_HOST}" ]; then
    MYSQL_HOST=${MYSQL_INPUT_HOST}
  fi

  if [ ! -z "${MYSQL_INPUT_DB_NAME}" ]; then
    MYSQL_DB_NAME=${MYSQL_INPUT_DB_NAME}
  fi

  fxTitle "💾 Storing MySQL credentials to ${FILENAME}..."
  echo "MYSQL_USER=$MYSQL_USER" > "$FILENAME"
  echo "MYSQL_PASSWORD=$MYSQL_PASS" >> "$FILENAME"
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
  mysql -u${MYSQL_USER} -p"${MYSQL_PASS}" -h ${MYSQL_HOST} -e "SHOW DATABASES;"
}
