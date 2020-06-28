#!/bin/bash
echo ""

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "Set the optimal permission set for a web project"
rootCheck

## Config file path from CLI (if any)
WEBPERMISSION_PROJECT_DIR=$1

while [ -z "$WEBPERMISSION_PROJECT_DIR" ] || [ ! -d "$WEBPERMISSION_PROJECT_DIR" ]
do
	read -p "Please provide the directory to work on: " WEBPERMISSION_PROJECT_DIR  < /dev/tty
done

printMessage "OK, will work on: $WEBPERMISSION_PROJECT_DIR"

printMessage "Resetting owners and permissions...."
chown root:root "${WEBPERMISSION_PROJECT_DIR}" -R
chmod ugo=rwx "${WEBPERMISSION_PROJECT_DIR}" -R

printMessage "Changing ownership and permissions..."
chown webstackup:www-data "${WEBPERMISSION_PROJECT_DIR}" -R
chmod u=rwX,g=rX,o= "${WEBPERMISSION_PROJECT_DIR}" -R

printMessage "SetGID on the root directory"
chmod g+s "${WEBPERMISSION_PROJECT_DIR}"

printMessage "SetGID on the directories inside..."
find "${WEBPERMISSION_PROJECT_DIR}" -type d -exec chmod g+s {} \;

if [[ -e "${WEBPERMISSION_PROJECT_DIR}website/www/script" ]]; then

    chmod u=rwx,go=rx "${WEBPERMISSION_PROJECT_DIR}website/www/script" -R
fi

printMessage "Web permissions applied!"
ls -la "$WEBPERMISSION_PROJECT_DIR"
