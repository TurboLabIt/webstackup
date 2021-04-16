#!/bin/bash
echo ""

## Script name
SCRIPT_NAME=letsencrypt-generate
LETSENCRYPT_DOMAIN=$1
LETSENCRYPT_EMAIL=$2

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


## Domain
while [ -z "$LETSENCRYPT_DOMAIN" ]
do
  read -p "Please provide the website domain to request the HTTPS certificate for (no-www! E.g.: turbolab.it): " LETSENCRYPT_DOMAIN  < /dev/tty
  
  if [ -z "${LETSENCRYPT_DOMAIN}" ]; then
  
    echo "Please provide the website domain!"
    continue
  fi
  
  echo "Domain: $LETSENCRYPT_DOMAIN"
  
  LETSENCRYPT_DOMAIN_2ND=$(echo "$LETSENCRYPT_DOMAIN" |  cut -d '.' -f 1)
  LETSENCRYPT_DOMAIN_TLD=$(echo "$LETSENCRYPT_DOMAIN" |  cut -d '.' -f 2)
  
  if [ -z "${LETSENCRYPT_DOMAIN_2ND}" ] || [ -z "${LETSENCRYPT_DOMAIN_TLD}" ] || [ "${LETSENCRYPT_DOMAIN_2ND}" == "${LETSENCRYPT_DOMAIN_TLD}" ]; then
  
    LETSENCRYPT_DOMAIN=    
    echo "Let's Encrypt error!"
    echo "Please provide a valid domain, such as: turbolab.it"
    continue
  fi
  
  echo "OK, this domain looks valid!"
  LETSENCRYPT_NEWSITE_NAME=${LETSENCRYPT_DOMAIN_2ND}_${LETSENCRYPT_DOMAIN_TLD}
  
  if [ -d "/etc/letsencrypt/live/${LETSENCRYPT_NEWSITE_NAME}" ]; then
  
    LETSENCRYPT_DOMAIN=
    
    echo "Let's Encrypt error!"
    echo "This domain already exists!"
    continue
  fi

done


## Email address (to get notifications from Let's Encrypt)
while [ -z "$LETSENCRYPT_EMAIL" ]
do
  read -p "Please provide the email address to receive notifications at: " LETSENCRYPT_EMAIL  < /dev/tty
  
  if [ -z "${LETSENCRYPT_EMAIL}" ]; then
  
    echo "Please provide the email address!"
    continue
  fi
  
  echo "Email: $LETSENCRYPT_EMAIL"
  
done


## Generate request
certbot --non-interactive --email $LETSENCRYPT_EMAIL --agree-tos certonly --webroot -w "/var/www/${LETSENCRYPT_NEWSITE_NAME}/website/www/public/" -d ${LETSENCRYPT_DOMAIN} -d www.${LETSENCRYPT_DOMAIN}


## Load certificates
service nginx reload

sleep 5
