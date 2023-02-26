#!/bin/bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "Server management GUI"
rootCheck

if [ -z "$(command -v dialog)" ]; then
  apt install dialog -y -qq
fi


HEIGHT=25
WIDTH=75
CHOICE_HEIGHT=30
BACKTITLE="WEBSTACK.UP - TurboLab.it"
TITLE="Web service management GUI"
MENU="Choose one task:"

OPTIONS=(
     1 "🔄 Web services turbo-restart"
     2 "♻️  Web services safe restart"
     3 "✔️  Self-update"
     4 "🚀  Git clone an existing app"
     5 "🧺  New database user access"
     6 "📧  DKIM a domain"
     7 "🔒  Let's Encrypt a domain"
     8 "🔑  Webpermissions a directory"
     9 "↗️  Show webstackup SSH pub key"
     10 "🔧 MySQL maintenance"
     11 "🏁 MySQL Tuner"
     12 "🤦 MySQL password reset"
     13 "🧪 WSU Dev (MAP test)"
     14 "🐫 my-app-template")

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
    curl -s https://raw.githubusercontent.com/TurboLabIt/zzalias/master/zzws.sh?$(date +%s) | sudo bash
  fi
}


case $CHOICE in
  1)
    wsuzzws
    ;;
  2)
    wsuzzws restart
    ;;
  3)
    git -C "${WEBSTACKUP_INSTALL_DIR}" reset --hard
    git -C "${WEBSTACKUP_INSTALL_DIR}" pull
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    wsuzzws
    ;;
  4)
    bash "${WEBSTACKUP_INSTALL_DIR}script/filesystem/git-clone-a-webapp.sh"
    ;;
  5)
    bash "${WEBSTACKUP_INSTALL_DIR}script/mysql/new.sh"
    ;;
  6)
    bash "${WEBSTACKUP_INSTALL_DIR}script/mail/dkim.sh"
    ;;
  7)
    bash "${WEBSTACKUP_INSTALL_DIR}script/https/letsencrypt-generate.sh"
    ;;
  8)
    bash "${WEBSTACKUP_INSTALL_DIR}script/filesystem/webpermission.sh"
    ;;
  9)
    printMessage "$(cat "/home/webstackup/.ssh/id_rsa.pub")"
    ;;
  10)
    bash "${WEBSTACKUP_SCRIPT_DIR}mysql/maintenance.sh"
    ;;
  11)
    bash "${WEBSTACKUP_INSTALL_DIR}script/mysql/mysqltuner.sh"
    ;;
  12)
    bash "${WEBSTACKUP_INSTALL_DIR}script/mysql/password-reset.sh"
    ;;
  13)
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    bash "${WEBSTACKUP_INSTALL_DIR}my-app-template/setup_test.sh"
    ;;
  14)
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    bash "${WEBSTACKUP_INSTALL_DIR}my-app-template/setup.sh"
    ;;
esac  
