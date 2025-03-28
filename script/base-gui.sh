#!/usr/bin/env bash

source "/usr/local/turbolab.it/webstackup/script/base.sh"
fxHeader "$TITLE"
rootCheck

if [ -z "$(command -v dialog)" ]; then
  apt install dialog -y -qq
fi

# Run only if LANG does NOT end with .UTF-8
if [[ ! "$CURRENT_LANG" =~ \.UTF-8$ ]]; then
    bash "${WEBSTACKUP_SCRIPT_DIR}system/emoji-support.sh"
fi


CHOICE=$(dialog --clear \
  --backtitle "$BACKTITLE" \
  --title "$TITLE" \
  --menu "$MENU" \
  $HEIGHT $WIDTH $CHOICE_HEIGHT \
  "${OPTIONS[@]}" \
  2>&1 >/dev/tty)

clear
