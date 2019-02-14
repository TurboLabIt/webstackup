#!/bin/bash
clear

## Script name
SCRIPT_NAME=newwordpress

## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

## 
source ${SCRIPT_DIR}newsite.sh

##
if [ -z "${NEWSITE_DIR}" ] || [ -z "${NEWSITE_HTDOCS}" ] || [ ! -d "${NEWSITE_HTDOCS}" ]; then

	printTitle "Error setting up newsite"
	printMessage "WordPress not installed"
	exit
fi

## 
curl -o "${NEWSITE_DIR}wordpress.zip" https://wordpress.org/latest.zip
unzip -o "${NEWSITE_DIR}wordpress.zip" -d "${NEWSITE_DIR}"
rm -f "${NEWSITE_DIR}wordpress.zip"
rm -rf "${NEWSITE_HTDOCS}"
mv "${NEWSITE_DIR}wordpress" "${NEWSITE_HTDOCS}"

## =========== Change owner and permission ===========
source "${SCRIPT_DIR}../filesystem/webpermission.sh" "${NEWSITE_HTDOCS}"

## =========== THE END ===========
printTitle "Your new WordPress is ready!"
printTitle "The End"
echo $(date)
echo "$FRAME"
