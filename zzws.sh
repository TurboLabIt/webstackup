#!/bin/bash
clear

## Script name
SCRIPT_NAME=webstackup

## Install directory
WORKING_DIR_ORIGINAL="$(pwd)"
INSTALL_DIR_PARENT="/usr/local/turbolab.it/"
INSTALL_DIR=${INSTALL_DIR_PARENT}${SCRIPT_NAME}/

if [ -z "$(command -v dialog)" ]; then

	apt install dialog -y -qq
fi

echo "Updating..."
git -C "${INSTALL_DIR}" pull

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
         5 "Web service restart"
		 6 "WEBSTACK.UP reinstall.")

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
            sudo bash "${INSTALL_DIR}script/nginx/new-site.sh"
            ;;
        2)
            sudo bash "${INSTALL_DIR}script/nginx/new-wordpress.sh"
            ;;
        3)
			sudo bash "${INSTALL_DIR}script/mail/dkim.sh"
			;;
		4)
			sudo bash "${INSTALL_DIR}script/letsencrypt/new.sh"
			;;
		5)
            sudo service nginx stop
			sudo service php7.3 stop
			sudo service mysql stop
			sleep 2
			sudo service mysql start
			sudo service php7.3 start
			sudo service nginx start
            ;;
		6)
			read -p "Are you sure? " -n 1 -r
			echo
			
			if [[ $REPLY =~ ^[Yy]$ ]]; then
			
				sudo bash "${INSTALL_DIR}webstackup.sh"
			fi
			;;
esac
