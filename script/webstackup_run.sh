#!/usr/bin/env bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
TITLE="Server management GUI"
fxHeader "$TITLE"
rootCheck

if [ -z "$(command -v dialog)" ]; then
  apt install dialog -y -qq
fi

OPTIONS=(
  1 "🔄   Web services turbo-restart"
  2 "♻️   Web services safe restart"
  3 "✔️   Self-update"
  4 "🐑   Git clone an existing app"
  5 "🛢️   MySQL GUI (zzdb)"
  6 "🔒   Let's Encrypt a domain"
  7 "👮   Webpermissions a directory"
  8 "🔑   Show webstackup SSH pub key"
  9 "💌   Email GUI (zzmail)"
  10 "🐫   my-app-template"
  #11 "🧪   WSU Dev (MAP test)"
)

CHOICE=$(dialog --clear \
  --backtitle "$BACKTITLE" \
  --title "$TITLE" \
  --menu "$MENU" \
  $HEIGHT $WIDTH $CHOICE_HEIGHT \
  "${OPTIONS[@]}" \
  2>&1 >/dev/tty)

clear


function wsuzzws()
{
  if [ -f "${WEBSTACKUP_INSTALL_DIR_PARENT}zzalias/zzws.sh" ]; then
    sudo bash ${WEBSTACKUP_INSTALL_DIR_PARENT}zzalias/zzws.sh $1
  else
    curl -s https://raw.githubusercontent.com/TurboLabIt/zzalias/master/zzws.sh | sudo bash
  fi
}


case $CHOICE in
  1)wsuzzws;;
  2)wsuzzws restart;;
  3)
    git -C "${WEBSTACKUP_INSTALL_DIR}" reset --hard
    git -C "${WEBSTACKUP_INSTALL_DIR}" pull
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    wsuzzws
    ;;
  4)
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    bash "${WEBSTACKUP_SCRIPT_DIR}mysql/new.sh"
    bash "${WEBSTACKUP_SCRIPT_DIR}filesystem/git-clone.sh"
    ;;
  5)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/zzdb.sh";;
  6)bash "${WEBSTACKUP_SCRIPT_DIR}https/letsencrypt-generate.sh";;
  7)bash "${WEBSTACKUP_SCRIPT_DIR}filesystem/webpermission.sh";;
  8)fxMessage "$(cat "/home/webstackup/.ssh/id_rsa.pub")";;
  9)bash "${WEBSTACKUP_SCRIPT_DIR}mail/zzmail.sh";;
  10)
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    bash "${WEBSTACKUP_INSTALL_DIR}my-app-template/setup.sh"
    ;;
  11)bash "${WEBSTACKUP_INSTALL_DIR}my-app-template/setup_test.sh";;
esac
