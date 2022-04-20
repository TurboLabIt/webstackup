#!/bin/bash

echo ""
echo -e "\e[1;46m ================= \e[0m"
echo -e "\e[1;46m 👮 WEB-PERMISSION \e[0m"
echo -e "\e[1;46m ================= \e[0m"

if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi

source "/usr/local/turbolab.it/webstackup/script/base.sh"

## Config file path from CLI (if any)
WEBPERMISSION_PROJECT_DIR=$1

while [ -z "$WEBPERMISSION_PROJECT_DIR" ] || [ ! -d "$WEBPERMISSION_PROJECT_DIR" ]
do
  read -p "Please provide the directory to work on: " WEBPERMISSION_PROJECT_DIR  < /dev/tty
done

printMessage "OK, will work on: $WEBPERMISSION_PROJECT_DIR"

printMessage "Reset the permissions to none..."
chmod ugo= "${WEBPERMISSION_PROJECT_DIR}" -R

printMessage "Setting the ownership for the whole tree to webstackup:www-data..."
chown webstackup:www-data "${WEBPERMISSION_PROJECT_DIR}" -R

printMessage "SetGID on the root directory only"
chmod g+s "${WEBPERMISSION_PROJECT_DIR}"

printMessage "All the file created will belong to creator:www-data"
find "${WEBPERMISSION_PROJECT_DIR}" -type d -exec chmod g+s {} \;

printMessage "Setting the permissions for the whole tree..."
chmod u=rwX,g=rX,o= "${WEBPERMISSION_PROJECT_DIR}" -R

if [[ -e "${WEBPERMISSION_PROJECT_DIR}website/www/script" ]]; then

    chmod u=rwx,go=rx "${WEBPERMISSION_PROJECT_DIR}website/www/script" -R
fi

printMessage "Web permissions applied!"
ls -la "$WEBPERMISSION_PROJECT_DIR"
