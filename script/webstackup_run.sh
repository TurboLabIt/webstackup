#!/bin/bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "Server management GUI"
rootCheck

if [ -z "$(command -v dialog)" ]; then
  apt install dialog -y -qq
fi


HEIGHT=20
WIDTH=75
CHOICE_HEIGHT=25
BACKTITLE="WEBSTACK.UP - TurboLab.it"
TITLE="Web service management GUI"
MENU="Choose one task:"

OPTIONS=(
     1 "🚀  Git clone an existing app"
     2 "🧺  New database user access"
     3 "📧  DKIM a domain"
     4 "🔒  Let's Encrypt a domain"
     5 "🔄  Web service reload"
     6 "🔄  Web service restart"
     7 "🔑  Webpermissions a directory"
     8 "↗️  Show webstackup SSH pub key"
     9 "✔️  Self-update"
     10 "🔧 MySQL maintenance"
     11 "🏁 MySQL Tuner"
     12 "🤦 MySQL password reset"
     13 "🐫 my-app-template")

CHOICE=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --menu "$MENU" \
        $HEIGHT $WIDTH $CHOICE_HEIGHT \
        "${OPTIONS[@]}" \
        2>&1 >/dev/tty)

clear
case $CHOICE in
  1)
    bash "${WEBSTACKUP_INSTALL_DIR}script/filesystem/git-clone-a-webapp.sh"
    ;;
  2)
    bash "${WEBSTACKUP_INSTALL_DIR}script/mysql/new.sh"
    ;;
  3)
    bash "${WEBSTACKUP_INSTALL_DIR}script/mail/dkim.sh"
    ;;
  4)
    bash "${WEBSTACKUP_INSTALL_DIR}script/https/letsencrypt-generate.sh"
    ;;
  5)
    zzws reload
    ;;
  6)
    zzws restart
    ;;
  7)
    bash "${WEBSTACKUP_INSTALL_DIR}script/filesystem/webpermission.sh"
    ;;
  8)
    printMessage "$(cat "/home/webstackup/.ssh/id_rsa.pub")"
    ;;
  9)
    git -C "${WEBSTACKUP_INSTALL_DIR}" reset --hard
    git -C "${WEBSTACKUP_INSTALL_DIR}" pull
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    nginx -t && service nginx restart
    /usr/sbin/php-fpm${PHP_VER} -t && service ${PHP_FPM} restart
    apachectl configtest && service apache2 restart
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
    bash "${WEBSTACKUP_INSTALL_DIR}my-app-template/setup.sh"
    ;;
esac  
