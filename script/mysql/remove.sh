#!/usr/bin/env bash
### AUTOMATIC MYSQL UNINSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/remove.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/remove.sh?$(date +%s) | sudo bash


## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧹 MySQL Remover"
rootCheck


fxTitle "Removing MySQL..."
service mysql stop
DEBIAN_FRONTEND=noninteractive apt purge --auto-remove mysql* -y


fxTitle "Removing data..."
rm -rf /var/lib/*mysql*


fxTitle "Removing config..."
rm -rf /etc/*mysql*


fxTitle "Removing repository-related files..."
rm -rf /etc/apt/trusted.gpg.d/*mysql*
rm -rf /etc/apt/sources.list.d/*mysql*


fxTitle "Removing cron files..."
rm -rf /etc/cron.d/*mysql*


fxEndFooter
