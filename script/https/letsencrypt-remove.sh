#!/usr/bin/env bash
### AUTOMATIC LET'S ENCRYPT UNINSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/https/letsencrypt-remove.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/letsencrypt-remove.sh?$(date +%s) | sudo bash


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


fxTitle "Listing current live domains..."
ls -la /etc/letsencrypt/live


fxTitle "Removing certbot..."
apt purge --auto-remove certbot* -y


fxTitle "Removing config and files..."
rm -rf /etc/letsencrypt/
rm -rf /var/lib/letsencrypt/
rm -rf /var/log/letsencrypt/


fxEndFooter
