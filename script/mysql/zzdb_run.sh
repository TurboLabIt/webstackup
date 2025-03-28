#!/usr/bin/env bash
### MySQL GUI by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/zzdb.sh

TITLE="MySQL management GUI"
OPTIONS=(
  1 "🐬  New database user access"
  2 "🔧  MySQL maintenance"
  3 "💨  MySQL Tuner"
  4 "🤦  MySQL password reset"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/new.sh";;
  2)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/maintenance.sh";;
  3)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/mysqltuner.sh";;
  4)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/password-reset.sh";;
esac
