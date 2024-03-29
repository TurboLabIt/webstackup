#!/bin/bash
echo ""

echo -e "\e[1;41m UNMAINTAINED as of 2022-04 \e[0m"
exit

## Script name
SCRIPT_NAME=new-wordpress

## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

## 
source ${SCRIPT_DIR}new-site.sh

##
if [ -z "${NEWSITE_DIR}" ] || [ -z "${NEW_WWW_PUBLIC_DIR}" ] || [ ! -d "${NEW_WWW_PUBLIC_DIR}" ]; then

  printTitle "Error setting up newsite"
  printMessage "WordPress not installed"
  exit
fi


## =========== Activate WP specifics in new vhost ===========
NGINX_WP_INCL1="include /usr/local/turbolab.it/webstackup/config/nginx/15_wordpress_location.conf;"
for NGINX_WP_INCL in "${NGINX_WP_INCL1}"
do
  sed -i -e "s|#${NGINX_WP_INCL}|${NGINX_WP_INCL}|g" "${NEWSITE_DIR}conf/nginx/${NEWSITE_NAME}.conf"
done


## =========== Download WordPress ===========
curl -o "${NEWSITE_DIR}wordpress.zip" https://wordpress.org/latest.zip
unzip -o "${NEWSITE_DIR}wordpress.zip" -d "${NEWSITE_DIR}"
rm -f "${NEWSITE_DIR}wordpress.zip"
rm -rf "${NEW_WWW_PUBLIC_DIR}"
mv "${NEWSITE_DIR}wordpress" "${NEW_WWW_PUBLIC_DIR}"


## =========== Set up config.php ===========
cp "${NEW_WWW_PUBLIC_DIR}wp-config-sample.php" "${NEW_WWW_PUBLIC_DIR}wp-config.php"
sed -i -e "s|database_name_here|$NEWSITE_NAME|g" "${NEW_WWW_PUBLIC_DIR}wp-config.php"
sed -i -e "s|username_here|$NEWSITE_NAME|g" "${NEW_WWW_PUBLIC_DIR}wp-config.php"
sed -i -e "s|password_here|$NEWSITE_DB_PASSWORD|g" "${NEW_WWW_PUBLIC_DIR}wp-config.php"
sed -i -e 's|utf8|utf8mb4|g' "${NEW_WWW_PUBLIC_DIR}wp-config.php"
php "${SCRIPT_DIR}new-wordpress_helper.php" "${NEW_WWW_PUBLIC_DIR}wp-config.php"


## =========== Change owner and permission ===========
source "${SCRIPT_DIR}../filesystem/webpermission.sh" "${NEW_WWW_PUBLIC_DIR}"


## =========== THE END ===========
printTitle "Your new WordPress is ready!"
printTitle "The End"
echo $(date)
echo "$FRAME"
