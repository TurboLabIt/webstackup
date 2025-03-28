#!/usr/bin/env bash
### MySQL GUI by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/zzdb.sh
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
TITLE="MySQL management GUI"
fxHeader "$TITLE"
rootCheck

if [ -z "$(command -v dialog)" ]; then
  apt install dialog -y -qq
fi

OPTIONS=(
  1 "🐬  New database user access"
  2 "🔧  MySQL maintenance"
  3 "💨  MySQL Tuner"
  4 "🤦  MySQL password reset"
)

CHOICE=$(dialog --clear \
  --backtitle "$BACKTITLE" \
  --title "$TITLE" \
  --menu "$MENU" \
  $HEIGHT $WIDTH $CHOICE_HEIGHT \
  "${OPTIONS[@]}" \
  2>&1 >/dev/tty)

clear


case $CHOICE in
  1)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/new.sh";;
  2)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/maintenance.sh";;
  3)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/mysqltuner.sh";;
  4)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/password-reset.sh";;
esac
