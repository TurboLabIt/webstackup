#!/usr/bin/env bash
### AUTOMATIC NGINX UNINSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/nginx/remove.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/nginx/remove.sh | sudo bash


## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧹 NGINX Remover"
rootCheck


fxTitle "Removing nginx..."
service nginx stop
DEBIAN_FRONTEND=noninteractive apt purge --auto-remove nginx* -y


fxTitle "Removing config..."
rm -rf /etc/*nginx*


fxTitle "Removing logs..."
rm -rf /var/log/nginx


fxTitle "Removing repository-related files..."
rm -rf /etc/apt/trusted.gpg.d/*nginx*
rm -rf /etc/apt/sources.list.d/*nginx*


fxTitle "Reloading service list..."
systemctl daemon-reload


fxTitle "Path to clean manually"
fxInfo /etc/cron.d
ls -l /etc/cron.d

fxInfo /var/www
ls -l /var/www
cd /var/www


fxEndFooter
