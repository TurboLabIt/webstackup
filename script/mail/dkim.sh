#!/bin/bash
echo ""

## Script name
SCRIPT_NAME=dkim

## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo "      $SCRIPT_NAME - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

MAIL_DOMAIN=$1

## root check
if ! [ $(id -u) = 0 ]; then

	echo ""
	echo "vvvvvvvvvvvvvvvvvvvv"
	echo "Catastrophic error!!"
	echo "^^^^^^^^^^^^^^^^^^^^"
	echo "This script must run as root!"

	echo "How to fix it?"
	echo "Execute the script like this:"
	echo "sudo $SCRIPT_NAME"

	echo "The End"
	echo $(date)
	exit
fi


while [ -z "$MAIL_DOMAIN" ]
do
	read -p "Please provide the email domain to DKIM (no-www! E.g.: turbolab.it): " MAIL_DOMAIN  < /dev/tty
	
	if [ -z "${MAIL_DOMAIN}" ]; then
	
		echo "Please provide the email domain to DKIM!"
		continue
	fi
	
	echo "Domain: $MAIL_DOMAIN"
	
	MAIL_DOMAIN_2ND=$(echo "$MAIL_DOMAIN" |  cut -d '.' -f 1)
	MAIL_DOMAIN_TLD=$(echo "$MAIL_DOMAIN" |  cut -d '.' -f 2)
	
	if [ -z "${MAIL_DOMAIN_2ND}" ] || [ -z "${MAIL_DOMAIN_TLD}" ] || [ "${MAIL_DOMAIN_2ND}" == "${MAIL_DOMAIN_TLD}" ]; then
	
		MAIL_DOMAIN=		
		echo "Mail error!"
		echo "Please provide a valid domain, such as: turbolab.it"
		continue
	fi
	
	echo "OK, this mail domain looks valid!"
	
	if [ -d "/etc/opendkim/keys/${MAIL_DOMAIN}" ]; then
	
		MAIL_DOMAIN=
		
		echo "Mail error!"
		echo "This domain already exists!"
		ls -la "/etc/opendkim/keys/${MAIL_DOMAIN}"
		continue
	fi

done


## Creating folders
mkdir -p /etc/opendkim/keys/${MAIL_DOMAIN}
opendkim-genkey -D "/etc/opendkim/keys/${MAIL_DOMAIN}/" -d "${MAIL_DOMAIN}" -s default
chown -R opendkim:opendkim /etc/opendkim/keys

## KeyTable
MAIL_KEYTABLE_FILE="/etc/opendkim/KeyTable"
echo '' >> "$MAIL_KEYTABLE_FILE"
echo "## Domain: ${MAIL_DOMAIN}" >> "$MAIL_KEYTABLE_FILE"
echo "default._domainkey.${MAIL_DOMAIN} ${MAIL_DOMAIN}:default:/etc/opendkim/keys/${MAIL_DOMAIN}/default.private" >> "$MAIL_KEYTABLE_FILE"

## SigningTable
MAIL_SIGNTABLE_FILE="/etc/opendkim/SigningTable"
echo '' >> "$MAIL_SIGNTABLE_FILE"
echo "## Domain: ${MAIL_DOMAIN}" >> "$MAIL_SIGNTABLE_FILE"
echo "*@${MAIL_DOMAIN} default._domainkey.${MAIL_DOMAIN}" >> "$MAIL_SIGNTABLE_FILE"

service opendkim restart
systemctl --no-pager status opendkim 
sleep 5
