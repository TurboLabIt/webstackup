#!/usr/bin/env bash
### MySQL GUI by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/zzdb.sh

TITLE="MySQL management GUI"
OPTIONS=(
  1 "🚪  Login to MySQL"
  2 "🐬  New database user access"
  3 "🔧  MySQL maintenance"
  4 "💨  MySQL Tuner"
  5 "🤦  MySQL password reset"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1)
    source /etc/turbolab.it/mysql.conf
    mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h"${MYSQL_HOST}"
    ;;
  2)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/new.sh";;
  3)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/maintenance.sh";;
  4)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/mysqltuner.sh";;
  5)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/password-reset.sh";;
esac
