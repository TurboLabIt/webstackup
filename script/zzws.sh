#!/bin/bash
clear

## Script name
SCRIPT_NAME=webstackup

## Install directory
WORKING_DIR_ORIGINAL="$(pwd)"
INSTALL_DIR_PARENT="/usr/local/turbolab.it/"
INSTALL_DIR=${INSTALL_DIR_PARENT}${SCRIPT_NAME}/

## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")
ZZWS_SCRIPT_HASH=`md5sum ${SCRIPT_FULLPATH} | awk '{ print $1 }'`


## If no argument is proveded, display the GUI
if [ -z "$1" ]; then

	if [ -z "$(command -v dialog)" ]; then

		apt install dialog -y -qq
	fi

	echo "Updating..."
	git -C "${INSTALL_DIR}" pull

	ZZWS_SCRIPT_HASH_AFTER_UPDATE=`md5sum ${SCRIPT_FULLPATH} | awk '{ print $1 }'`
	if [ "$ZZWS_SCRIPT_HASH" != "$ZZWS_SCRIPT_HASH_AFTER_UPDATE" ]; then

		echo ""
		echo "vvvvvvvvvvvvvvvvvvvvvv"
		echo "Self-update installed!"
		echo "^^^^^^^^^^^^^^^^^^^^^^"
		echo "This script itself has been updated!"
		echo "Please run zzws again."

		echo $(date)
		exit
	fi

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
			 7 "WEBSTACK.UP reinstall."
			 8 "Self-update")

	CHOICE=$(dialog --clear \
					--backtitle "$BACKTITLE" \
					--title "$TITLE" \
					--menu "$MENU" \
					$HEIGHT $WIDTH $CHOICE_HEIGHT \
					"${OPTIONS[@]}" \
					2>&1 >/dev/tty)


## if an argument is provided via CLI, select action from above
else

	case $1 in
			reload)
				CHOICE=5
				;;
			restart)
				CHOICE=6
				;;
	esac
fi


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
			sudo bash "${INSTALL_DIR}script/zzws-service.sh" reload
            ;;
		6)
			sudo bash "${INSTALL_DIR}script/zzws-service.sh" restart
            ;;
		7)
			read -p "Are you sure? " -n 1 -r
			echo
			
			if [[ $REPLY =~ ^[Yy]$ ]]; then
			
				sudo bash "${INSTALL_DIR}webstackup.sh"
			fi
			;;
		8)
			git -C "${INSTALL_DIR}" pull
			;;
esac
