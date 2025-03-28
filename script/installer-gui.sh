#!/usr/bin/env bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
TITLE="Software installer"
fxHeader "$TITLE"
rootCheck

if [ -z "$(command -v dialog)" ]; then
  apt install dialog -y -qq
fi

OPTIONS=(
  1 "💿  node.js, yarn, webpack"
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
  1)bash "${WEBSTACKUP_SCRIPT_DIR}node.js/install.sh";;
esac
