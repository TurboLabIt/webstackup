#!/bin/bash
echo ""

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "Create a new project"
rootCheck

## New website data from CLI (if any)
NEWSITE_DOMAIN=$1


## =========== Get directory ===========
checkInputDomain ()
{	
	if [ -z "${NEWSITE_DOMAIN}" ]; then
	
		return 0
	fi
	
	printMessage "Domain: $NEWSITE_DOMAIN"

	NEWSITE_DOMAIN_2ND=$(echo "$NEWSITE_DOMAIN" |  cut -d '.' -f 1)
	NEWSITE_DOMAIN_TLD=$(echo "$NEWSITE_DOMAIN" |  cut -d '.' -f 2)
	NEWSITE_DOMAIN_3RD=$(echo "$NEWSITE_DOMAIN" |  cut -d '.' -f 3)
	
	if [ ! -z "${NEWSITE_DOMAIN_3RD}" ] || [ -z "${NEWSITE_DOMAIN_2ND}" ] || [ -z "${NEWSITE_DOMAIN_TLD}" ] || [ "${NEWSITE_DOMAIN_2ND}" == "${NEWSITE_DOMAIN_TLD}" ]; then
	
		NEWSITE_DOMAIN=
		
		printLightWarning "Domain error!"
		return 0
	fi
	
	printMessage "OK, this website domain looks valid!"

	NEWSITE_NAME=${NEWSITE_DOMAIN_2ND}_${NEWSITE_DOMAIN_TLD}
	printMessage "Directory and database: $NEWSITE_NAME"

	NEW_PROPERTY_DIR=/var/www/${NEWSITE_NAME}/
	printMessage "Full path: $NEW_PROPERTY_DIR"
	
	if [ -d "${NEW_PROPERTY_DIR}" ]; then
	
		NEWSITE_DOMAIN=
		
		printLightWarning "Domain error!"
		printMessage "This website already exists!"
		ls -la "${NEW_PROPERTY_DIR}"
		return 0
	fi
}


## Check the domain provided as argument from CLI (if any)
checkInputDomain


## Ask the user interactively
while [ -z "$NEWSITE_DOMAIN" ]
do
	read -p "Please provide the new website domain (no-www! E.g.: turbolab.it): " NEWSITE_DOMAIN  < /dev/tty	
	checkInputDomain
done

printMessage "This domain is not served from here yet..."
NEW_WWW_DIR="${NEW_PROPERTY_DIR}website/www/"
NEW_WWW_PUBLIC_DIR="${NEW_WWW_DIR}public/"
printMessage "Full path: ${NEW_WWW_PUBLIC_DIR}"


## =========== Directory tree ===========
printMessage "Creating directory tree..."
mkdir -p "${NEW_WWW_PUBLIC_DIR}"
curl -o "${NEW_WWW_PUBLIC_DIR}file_esempio.zip" https://turbolab.it/scarica/145
unzip -o "${NEW_WWW_PUBLIC_DIR}file_esempio.zip" -d "${NEW_WWW_PUBLIC_DIR}"
rm -f "${NEW_WWW_PUBLIC_DIR}file_esempio.zip"

mkdir -p "${NEW_WWW_DIR}script/"

mkdir -p "${NEW_WWW_DIR}backup/"
curl -o "${NEW_WWW_DIR}backup/.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore_contents?$(date +%s)

mkdir -p "${NEW_WWW_DIR}var/log/"
curl -o "${NEW_WWW_DIR}var/log/.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore_contents?$(date +%s)

echo '## A new project kickstarted with Webstackup ##' > "${NEW_PROPERTY_DIR}readme.md"


## =========== HTTPS Certificate ===========
source ${WEBSTACKUP_INSTALL_DIR}script/https/self-sign-generate.sh ${NEWSITE_DOMAIN}


## =========== nginx ===========
printMessage "Setting up NGINX..."
mkdir -p "${NEW_PROPERTY_DIR}conf/nginx/"
cp "${WEBSTACKUP_INSTALL_DIR}config/nginx/website_template.conf" "${NEW_PROPERTY_DIR}conf/nginx/${NEWSITE_NAME}.conf"
sed -i -e "s/localhost_tld/${NEWSITE_NAME}/g" "${NEW_PROPERTY_DIR}conf/nginx/${NEWSITE_NAME}.conf"
sed -i -e "s/localhost/${NEWSITE_DOMAIN}/g" "${NEW_PROPERTY_DIR}conf/nginx/${NEWSITE_NAME}.conf"
sed -i -e "s|/usr/share/nginx/html|${NEW_WWW_PUBLIC_DIR}|g" "${NEW_PROPERTY_DIR}conf/nginx/${NEWSITE_NAME}.conf"
ln -s "${NEW_PROPERTY_DIR}conf/nginx/${NEWSITE_NAME}.conf" "/etc/nginx/conf.d/${NEWSITE_NAME}.conf"

cp "${WEBSTACKUP_INSTALL_DIR}config/nginx/website_template_https.conf" "${NEW_PROPERTY_DIR}conf/nginx/https.conf"
sed -i -e "s/localhost/${NEWSITE_DOMAIN}/g" "${NEW_PROPERTY_DIR}conf/nginx/https.conf"
sed -i -e "s|/usr/share/nginx/html|${NEW_WWW_PUBLIC_DIR}|g" "${NEW_PROPERTY_DIR}conf/nginx/https.conf"

service nginx restart
systemctl  --no-pager status nginx
sleep 5


## =========== php ===========
printMessage "Setting up PHP..."
mkdir -p "${NEW_PROPERTY_DIR}conf/php/"
cp "${WEBSTACKUP_INSTALL_DIR}config/php/website_template.ini" "${NEW_PROPERTY_DIR}conf/php/${NEWSITE_NAME}.ini"
sed -i -e "s/localhost/${NEWSITE_DOMAIN}/g" "${NEW_PROPERTY_DIR}conf/php/${NEWSITE_NAME}.ini"
sed -i -e "s|/usr/share/nginx/|${NEW_WWW_PUBLIC_DIR}|g" "${NEW_PROPERTY_DIR}conf/php/${NEWSITE_NAME}.ini"
ln -s "${NEW_PROPERTY_DIR}conf/php/${NEWSITE_NAME}.ini" "/etc/php/${PHP_VER}/fpm/conf.d/22-webstackup-${NEWSITE_NAME}.ini"
ln -s "${NEW_PROPERTY_DIR}conf/php/${NEWSITE_NAME}.ini" "/etc/php/${PHP_VER}/cli/conf.d/22-webstackup-${NEWSITE_NAME}.ini"
service ${PHP_FPM} restart
systemctl  --no-pager status ${PHP_FPM}
sleep 5


## =========== Database ===========
printMessage "Setting up ZZMYSQLDUMP..."
ZZMYSQLDUMP_DIR="${WEBSTACKUP_INSTALL_DIR_PARENT}zzmysqldump/"
for ZZMYSQLDUMP_CONFIGFILE_FULLPATH in "${ZZMYSQLDUMP_DIR}zzmysqldump.default.conf" "/etc/turbolab.it/mysql.conf" "/etc/turbolab.it/zzmysqldump.conf" "${ZZMYSQLDUMP_DIR}zzmysqldump.conf" 
do
	if [ -f "$ZZMYSQLDUMP_CONFIGFILE_FULLPATH" ]; then

		source "$ZZMYSQLDUMP_CONFIGFILE_FULLPATH"
	fi
done


if [ ! -z "${MYSQL_PASSWORD}" ]; then

	printMessage "Creating database..."
	MYSQL_EXE="mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD}"
	NEWSITE_DB_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
	$MYSQL_EXE -e "CREATE USER '$NEWSITE_NAME'@'localhost' IDENTIFIED BY '$NEWSITE_DB_PASSWORD';"
	$MYSQL_EXE -e "CREATE DATABASE \`$NEWSITE_NAME\`;"
	$MYSQL_EXE -e "GRANT ALL PRIVILEGES ON \`${NEWSITE_NAME//_/\\_}%\`.* TO '$NEWSITE_NAME'@'localhost';"
	$MYSQL_EXE -e "FLUSH PRIVILEGES;"
	
	MYSQL_CREDENTIALS_DIR="${NEW_PROPERTY_DIR}conf/mysql/"
	MYSQL_CREDENTIALS_FULLPATH="${MYSQL_CREDENTIALS_DIR}mysql.conf"
	
	printMessage "Writing MySQL credentials to ${MYSQL_CREDENTIALS_FULLPATH}"
	mkdir -p "${MYSQL_CREDENTIALS_DIR}"
	echo "MYSQL_USER='$NEWSITE_NAME'" > "${MYSQL_CREDENTIALS_FULLPATH}"
	echo "MYSQL_PASSWORD='$NEWSITE_DB_PASSWORD'" >> "${MYSQL_CREDENTIALS_FULLPATH}"
	chown root:root "${MYSQL_CREDENTIALS_FULLPATH}"
	chmod u=r,go= "${MYSQL_CREDENTIALS_FULLPATH}"
	printMessage "$(cat "${MYSQL_CREDENTIALS_FULLPATH}")"
fi

## =========== DKIM ===========
source "${WEBSTACKUP_INSTALL_DIR}script/mail/dkim.sh" "$NEWSITE_DOMAIN"


## =========== Change owner and permission ===========
source "${WEBSTACKUP_INSTALL_DIR}script/filesystem/webpermission.sh" "${NEW_PROPERTY_DIR}"


## =========== Show results ===========
printMessage "Your new website is ready!"
ls -la "$NEW_WWW_PUBLIC_DIR"