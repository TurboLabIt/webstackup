#!/usr/bin/env bash
### AUTOMATIC LET'S ENCRYPT UNINSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/https/letsencrypt-remove.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/letsencrypt-remove.sh | sudo bash


## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "🧹 Let's Encrypt Remover"
rootCheck


fxTitle "Listing current live domain(s)..."
ls -la /etc/letsencrypt/live


fxTitle "Removing any old previous instance..."
rm -rf /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt /usr/local/bin/acme-dns-client
apt purge --auto-remove certbot* -y
snap remove --purge certbot
rm -rf /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt /usr/local/bin/acme-dns-client


fxTitle "Reloading services..."
if [ -f /usr/local/turbolab.it/webstackup/script/https/certificate-renewal-action.sh ]; then
  source /usr/local/turbolab.it/webstackup/script/https/certificate-renewal-action.sh
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/letsencrypt-remove.sh | sudo bash
fi


fxEndFooter
