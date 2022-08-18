#!/usr/bin/env bash
### READY-TO-RUN, FULLY CUSTOMIZED MYSQL COMMANDS BY WEBSTACK.UP
#
# wsuMySQL < myfile.sql

if [ -r "/etc/turbolab.it/mysql.conf" ]; then
  MYSQL_HOST=127.0.0.1
  source "/etc/turbolab.it/mysql.conf"
fi


function wsuMysql()
{
  mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" "$@"
}
