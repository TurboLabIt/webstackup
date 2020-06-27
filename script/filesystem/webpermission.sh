#!/bin/bash
clear

## Script name
SCRIPT_NAME=webpermission

## Install directory
WORKING_DIR_ORIGINAL="$(pwd)"
INSTALL_DIR_PARENT="/usr/local/turbolab.it/"
INSTALL_DIR=${INSTALL_DIR_PARENT}${SCRIPT_NAME}/

## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo "      $SCRIPT_NAME - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

## Config file path from CLI (if any)
FOLDER_FULLPATH=$1


## Title printing function
function printTitle
{
	STYLE='\033[44m'
	RESET='\033[0m'

    echo ""
	echo -n -e $STYLE
    echo "$1"
    printf '%0.s-' $(seq 1 ${#1})
	echo -e $RESET
	echo ""
}


function printMessage
{
	STYLE='\033[45m'
	RESET='\033[0m'

	echo -n -e $STYLE
    echo "$1"
	echo -e $RESET
	echo ""
}


## root check
if ! [ $(id -u) = 0 ]; then

	echo ""
	echo "vvvvvvvvvvvvvvvvvvvv"
	echo "Catastrophic error!!"
	echo "^^^^^^^^^^^^^^^^^^^^"
	echo "This script must run as root!"

	printTitle "How to fix it?"
	echo "Execute the script like this:"
	echo "sudo $SCRIPT_NAME"

	printTitle "The End"
	echo $(date)
	echo "$FRAME"
	exit
fi


## =========== Get directory ===========
while [ -z "$PROJECT_DIR" ] || [ ! -d "$PROJECT_DIR" ]
do
	read -p "Please provide the directory to work on: " PROJECT_DIR  < /dev/tty
done

printTitle "OK, will work on:"
printMessage "$PROJECT_DIR"


## =========== Change owner and permission ===========
printTitle "Changing ownership and permissions"

chown webstackup:www-data "${PROJECT_DIR}" -R
chmod g+s "${PROJECT_DIR}" -R
find "$PROJECT_DIR" -type f -exec chmod 660 {} +
find "$PROJECT_DIR" -type d -exec chmod 770 {} +

find "$FOLDER_FULLPATH" -type f -name 'wp-config.php' -exec chmod 440 {} +

if [[ -e "${PROJECT_DIR}website/www/script" ]]; then

    chmod u=rwx,go=rx "${PROJECT_DIR}www/script" -R
fi


## =========== Show results ===========
printTitle "Web permissions applied!"
ls -la "$FOLDER_FULLPATH"


## =========== THE END ===========
printTitle "The End"
echo $(date)
echo "$FRAME"
