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
  local MYSQL_PASS=$2
  local MYSQL_HOST=$3
  local FILENAME=$4
  local MYSQL_DB_NAME=$5

  fxTitle "💾 Storing MySQL credentials to ${FILENAME}..."
  echo "MYSQL_USER=$MYSQL_USER" > "$FILENAME"
  echo "MYSQL_PASSWORD=$MYSQL_PASS" >> "$FILENAME"
  echo "MYSQL_HOST=$MYSQL_HOST" >> "$FILENAME"
  
  if [ ! -z "MYSQL_DB_NAME" ]; then
    echo "MYSQL_DB_NAME=$MYSQL_DB_NAME" >> "$FILENAME"
  fi
  
  fxOK
}
