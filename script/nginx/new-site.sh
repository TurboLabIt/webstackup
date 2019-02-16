#!/bin/bash
clear

## Script name
SCRIPT_NAME=new-site

## Install directory
WORKING_DIR_ORIGINAL="$(pwd)"
INSTALL_DIR_PARENT="/usr/local/turbolab.it/"
INSTALL_DIR=${INSTALL_DIR_PARENT}webstackup/
WEB_DIR_ALL="/home/"

## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo "      $SCRIPT_NAME - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

## New website data from CLI (if any)
NEWSITE_DOMAIN=$1

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
while [ -z "$NEWSITE_DOMAIN" ]
do
	read -p "Please provide the new website domain (no-www! E.g.: turbolab.it): " NEWSITE_DOMAIN  < /dev/tty
	
	if [ -z "${NEWSITE_DOMAIN}" ]; then
	
		printMessage "Please provide the website domain to create!"
		continue
	fi
	
	printMessage "Domain: $NEWSITE_DOMAIN"
	
	NEWSITE_DOMAIN_2ND=$(echo "$NEWSITE_DOMAIN" |  cut -d '.' -f 1)
	NEWSITE_DOMAIN_TLD=$(echo "$NEWSITE_DOMAIN" |  cut -d '.' -f 2)
	
	if [ -z "${NEWSITE_DOMAIN_2ND}" ] || [ -z "${NEWSITE_DOMAIN_TLD}" ] || [ "${NEWSITE_DOMAIN_2ND}" == "${NEWSITE_DOMAIN_TLD}" ]; then
	
		NEWSITE_DOMAIN=		
		printTitle "Website error!"
		printMessage "Please provide a valid domain, such as: turbolab.it"
		continue
	fi
	
	printMessage "OK, this website domain looks valid!"

	
	NEWSITE_NAME=${NEWSITE_DOMAIN_2ND}_${NEWSITE_DOMAIN_TLD}
	printMessage "Directory and database: $NEWSITE_NAME"

	NEWSITE_DIR="${WEB_DIR_ALL}${NEWSITE_NAME}/"
	printMessage "Full path: $NEWSITE_DIR"
	
	if [ -d "${NEWSITE_DIR}" ]; then
	
		NEWSITE_DOMAIN=
		
		printTitle "Website error!"
		printMessage " This website already exists!"
		ls -la "${NEWSITE_DIR}"
		continue
	fi

done

printMessage "This domain is not served from here yet..."
NEWSITE_HTDOCS="${NEWSITE_DIR}website/www/htdocs/"
printMessage "Full path: $NEWSITE_HTDOCS"


## =========== Directory tree ===========
printTitle "Creating directory tree"
mkdir -p "${NEWSITE_DIR}conf/nginx/"
cp "${INSTALL_DIR}config/nginx/website_template.conf" "${NEWSITE_DIR}conf/nginx/${NEWSITE_NAME}.conf"
sed -i -e "s/localhost/${NEWSITE_DOMAIN}/g" "${NEWSITE_DIR}conf/nginx/${NEWSITE_NAME}.conf"
sed -i -e "s|/usr/share/nginx/html|${NEWSITE_HTDOCS}|g" "${NEWSITE_DIR}conf/nginx/${NEWSITE_NAME}.conf"

mkdir -p "${NEWSITE_HTDOCS}"
curl -o "${NEWSITE_HTDOCS}file_esempio.zip" https://turbolab.it/scarica/145
unzip -o "${NEWSITE_HTDOCS}file_esempio.zip" -d "${NEWSITE_HTDOCS}"
rm -f "${NEWSITE_HTDOCS}file_esempio.zip"

mkdir -p "${NEWSITE_DIR}script/"


## =========== Nginx ===========
ln -s "${NEWSITE_DIR}conf/nginx/${NEWSITE_NAME}.conf" "/etc/nginx/conf.d/${NEWSITE_NAME}.conf"
service nginx restart
systemctl  --no-pager status nginx
#sleep 5


## =========== Database ===========
ZZMYSQLDUMP_DIR="${INSTALL_DIR_PARENT}zzmysqldump/"

for ZZMYSQLDUMP_CONFIGFILE_FULLPATH in "${ZZMYSQLDUMP_DIR}zzmysqldump.default.conf" "/etc/turbolab.it/mysql.conf" "/etc/turbolab.it/zzmysqldump.conf" "${ZZMYSQLDUMP_DIR}zzmysqldump.conf" 
do
	if [ -f "$ZZMYSQLDUMP_CONFIGFILE_FULLPATH" ]; then

		source "$ZZMYSQLDUMP_CONFIGFILE_FULLPATH"
	fi
done


if [ ! -z "${MYSQL_PASSWORD}" ]; then

	printTitle "Creating database..."
	MYSQL_EXE="mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD}"
	NEWSITE_DB_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
	$MYSQL_EXE -e "CREATE USER '$NEWSITE_NAME'@'localhost' IDENTIFIED BY '$NEWSITE_DB_PASSWORD';"
	$MYSQL_EXE -e "CREATE DATABASE $NEWSITE_NAME;"
	$MYSQL_EXE -e "GRANT ALL PRIVILEGES ON $NEWSITE_NAME.* TO '$NEWSITE_NAME'@'localhost';"
	$MYSQL_EXE -e "FLUSH PRIVILEGES;"
	
	MYSQL_CREDENTIALS_DIR="${NEWSITE_DIR}conf/mysql/"
	MYSQL_CREDENTIALS_FULLPATH="${MYSQL_CREDENTIALS_DIR}mysql.conf"
	printTitle "Writing MySQL credentials to ${MYSQL_CREDENTIALS_FULLPATH}"
	mkdir -p "${MYSQL_CREDENTIALS_DIR}"
	echo "MYSQL_USER='$NEWSITE_NAME'" > "${MYSQL_CREDENTIALS_FULLPATH}"
	echo "MYSQL_PASSWORD='$NEWSITE_DB_PASSWORD'" >> "${MYSQL_CREDENTIALS_FULLPATH}"
	chown root:root "${MYSQL_CREDENTIALS_FULLPATH}"
	chmod u=r,go= "${MYSQL_CREDENTIALS_FULLPATH}"
	printMessage "$(cat "${MYSQL_CREDENTIALS_FULLPATH}")"
fi


## =========== Change owner and permission ===========
source "${INSTALL_DIR}script/filesystem/webpermission.sh" "${NEWSITE_HTDOCS}"


## =========== Show results ===========
printTitle "Your new website is ready!"
ls -la "$NEWSITE_DIR"
ls -la "$NEWSITE_HTDOCS"


## =========== THE END ===========
printTitle "The End"
echo $(date)
echo "$FRAME"
