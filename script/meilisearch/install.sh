#!/usr/bin/env bash
### AUTOMATIC MEILISEARCH INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/meilisearch/install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/meilisearch/install.sh | sudo bash
#
# Based on: https://www.meilisearch.com/docs/learn/self_hosted/install_meilisearch_locally#apt

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 MEILISEARCH installer"
rootCheck


fxTitle "Removing any old previous instance..."
apt purge --auto-remove meilisearch* -y


fxTitle "Adding the meilisearch repository..."
echo "deb [trusted=yes] https://apt.fury.io/meilisearch/ /" > /etc/apt/sources.list.d/fury.list


## https://github.com/TurboLabIt/webstackup/blob/master/script/account/generate-www-data.sh
curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/generate-www-data.sh | sudo bash


fxTitle "Generating the masterkey..."
MEILISEARCH_MASTERKEY="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"

MEILISEARCH_MASTERKEY_FULLPATH="/etc/turbolab.it/meilisearch-masterkey"
fxTitle "Saving the masterkey to ${MEILISEARCH_MASTERKEY_FULLPATH}..."
echo "${MEILISEARCH_MASTERKEY}" > "${MEILISEARCH_MASTERKEY_FULLPATH}"
fxMessage "$(cat "${MEILISEARCH_MASTERKEY_FULLPATH}")"


fxTitle "apt install meilisearch..."
apt update -qq
apt install meilisearch -y


fxEndFooter
