#!/usr/bin/env bash
### AUTOMATIC ELASTIC SEARCH UNINSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/elasticsearch/remove.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/elasticsearch/remove.sh | sudo bash


## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧹 Elastic Search Remover"
rootCheck


fxTitle "Removing elasticsearch..."
service elasticsearch stop
DEBIAN_FRONTEND=noninteractive apt purge --auto-remove elasticsearch* -y


rm -f /usr/share/keyrings/elasticsearch.gpg
rm -f /etc/apt/sources.list.d/elasticsearch.list
rm -f /etc/apt/preferences.d/99elasticsearch

fxEndFooter
