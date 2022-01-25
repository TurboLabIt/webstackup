#!/bin/bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "Server management GUI"
rootCheck

if [ -z "$(command -v dialog)" ]; then

  apt install dialog -y -qq
fi


HEIGHT=17
WIDTH=65
CHOICE_HEIGHT=25
BACKTITLE="WEBSTACK.UP - TurboLab.it"
TITLE="Web service management GUI"
MENU="Choose one of the options:"

OPTIONS=(
     1 "🚀  Git clone an existing app"
     2 "  New database user access"
     3 "📧  DKIM a domain"
     4 "🔒  Let's Encrypt a domain"
     5 "🔄  Web service reload"
     6 "🔄  Web service restart"
     7 "🔑  Webpermissions a directory"
     8 "↗️  Show webstackup SSH public key"
     9 "✔️  Self-update")

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
            #bash "${WEBSTACKUP_INSTALL_DIR}script/nginx/new-site.sh"
            bash "${WEBSTACKUP_INSTALL_DIR}script/filesystem/git-clone-a-webapp.sh"
            ;;
        2)
            #bash "${WEBSTACKUP_INSTALL_DIR}script/nginx/new-wordpress.sh"
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
      git -C "${WEBSTACKUP_INSTALL_DIR}" pull
      nginx -t && service nginx restart
      service ${PHP_FPM} restart
      ;;
esac  
