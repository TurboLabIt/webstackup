#!/usr/bin/env bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "🔏 HTTPS CERTIFICATE GENERATOR"
rootCheck


fxTitle "📛 Enter the domain"
fxInfo "For example: \"turbolab.it\" or \"next.turbolab.it\""
while [ -z "$WSU_MAP_DOMAIN_DEFAULT" ]; do

  echo "🤖 Provide the domain ⚠️ no 'WWW.' here!"
  read -p ">> " WSU_MAP_DOMAIN_DEFAULT  < /dev/tty

done

fxOK "OK, working on ##$WSU_MAP_DOMAIN_DEFAULT##"


fxTitle "🌍 WWW check"
dot_count=$(grep -o '\.' <<< "$WSU_MAP_DOMAIN_DEFAULT" | wc -l)

if [[ $dot_count -eq 1 ]]; then
  
  fxOK "Great, ##${WSU_MAP_DOMAIN_DEFAULT}## is a second-level domain!"

  echo "🤖 Add WWW.${WSU_MAP_DOMAIN_DEFAULT} to the certificate too? Hit Enter for 'yes'"
  read -p ">> " -n 1 -r  < /dev/tty
  if [[ ! "$REPLY" =~ ^[Nn0]$ ]]; then
    WSU_MAP_DOMAIN_WWW="-d www.${WSU_MAP_DOMAIN_DEFAULT}"
  fi
  
else

  fxInfo "The domain ##${WSU_MAP_DOMAIN_DEFAULT}## is NOT second-level. Skipping WWW 🦘"
fi


fxTitle "📂 Enter the path to webroot directory"
WSU_WEBROOT_PATH_DEFAULT=/var/www/${WSU_MAP_DOMAIN_DEFAULT}/public
while [ -z "$WSU_WEBROOT_PATH" ]; do

  echo "🤖 Provide the path (use TAB!) or hit Enter for ##${WSU_WEBROOT_PATH_DEFAULT}##"
  read -ep ">> " WSU_WEBROOT_PATH  < /dev/tty
  if [ -z "$WSU_WEBROOT_PATH" ]; then
    WSU_WEBROOT_PATH=$WSU_WEBROOT_PATH_DEFAULT
  fi

done

WSU_WEBROOT_PATH=${WSU_WEBROOT_PATH%*/}/
fxOK "Aye, aye! The webroot path is ##$WSU_WEBROOT_PATH##"


fxTitle "✉️ Provide the administrator email address"
fxInfo "It's required to create an account"
while [ -z "$WSU_HTTPS_EMAIL_ADDRESS" ]; do

  echo "🤖 Provide the email address"
  read -p ">> " WSU_HTTPS_EMAIL_ADDRESS  < /dev/tty

done

fxOK "OK, ##$WSU_HTTPS_EMAIL_ADDRESS##"


fxTitle "Building command..."
WSU_CERTBOT_REQUEST="certbot certonly --email $WSU_HTTPS_EMAIL_ADDRESS --no-eff-email --agree-tos --webroot -w ${WSU_WEBROOT_PATH} -d ${WSU_MAP_DOMAIN_DEFAULT} ${WSU_MAP_DOMAIN_WWW}"
fxMessage "${WSU_CERTBOT_REQUEST}"


fxTitle "Requesting certificate (dry-run)..."
$WSU_CERTBOT_REQUEST --dry-run

if [ $? -ne 0 ]; then

  fxCatastrophicError "Failure!" proceed

else

  fxOK "dry-run worked! Doing it for real..."

  fxTitle "Requesting..."
  $WSU_CERTBOT_REQUEST

  if [ -f "/etc/letsencrypt/renewal-hooks/deploy/webstackup-certificate-renewal-action.sh" ]; then
    bash "/etc/letsencrypt/renewal-hooks/deploy/webstackup-certificate-renewal-action.sh"
  fi

fi


fxEndFooter
