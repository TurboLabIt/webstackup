#!/bin/bash
clear

source "/usr/local/webstackup/script/base.sh"
printHeader "Server management GUI"
rootCheck

if [ -z "$(command -v dialog)" ]; then

	sudo apt install dialog -y -qq
fi

echo "Updating..."
git -C "${WEBSTACKUP_INSTALL_DIR}" pull

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=10
BACKTITLE="WEBSTACK.UP - TurboLab.it"
TITLE="Web service management GUI"
MENU="Choose one of the following options:"

OPTIONS=(1 "New site (generic)"
		 2 "New WordPress site"
		 3 "DKIM a domain"
		 4 "Let's Encrypt a domain"
		 5 "Web service reload"
		 6 "Web service restart"
		 7 "Webpermissions a directory"
		 8 "WEBSTACK.UP reinstall.")

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
            sudo bash "${WEBSTACKUP_INSTALL_DIR}script/nginx/new-site.sh"
            ;;
        2)
            sudo bash "${WEBSTACKUP_INSTALL_DIR}script/nginx/new-wordpress.sh"
            ;;
        3)
			sudo bash "${WEBSTACKUP_INSTALL_DIR}script/mail/dkim.sh"
			;;
		4)
			sudo bash "${WEBSTACKUP_INSTALL_DIR}script/https/letsencrypt-generate.sh"
			;;
		5)
			sudo zzws reload
            ;;
		6)
			sudo zzws restart
            ;;
	    7)
			sudo bash "${WEBSTACKUP_INSTALL_DIR}script/filesystem/webpermission.sh"
			;;
esac
