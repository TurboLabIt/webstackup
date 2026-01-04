#!/usr/bin/env bash
### AUTOMATIC MEILISEARCH INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/meilisearch/install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/meilisearch/install.sh | sudo bash
#
# Based on: https://www.meilisearch.com/docs/learn/self_hosted/install_meilisearch_locally#apt
# Based on: https://www.meilisearch.com/docs/guides/running_production#step-4-run-meilisearch-as-a-service

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 MEILISEARCH installer"
rootCheck

MEILISEARCH_DATA_PATH=/var/lib/meilisearch/

fxTitle "Removing any old previous instance..."
apt purge --auto-remove meilisearch* -y


fxTitle "Adding the meilisearch repository..."
echo "deb [trusted=yes] https://apt.fury.io/meilisearch/ /" > /etc/apt/sources.list.d/fury.list


fxTitle "apt install meilisearch..."
apt update -qq && apt install jq meilisearch -y


fxTitle "Creating the meilisearch user..."
useradd -d /var/lib/meilisearch -s /bin/false -m -r meilisearch
rm -rf "${MEILISEARCH_DATA_PATH}"


fxTitle "Creating the data directories in ##${MEILISEARCH_DATA_PATH}##..."
mkdir -p "${MEILISEARCH_DATA_PATH}data"
mkdir -p "${MEILISEARCH_DATA_PATH}dumps"
mkdir -p "${MEILISEARCH_DATA_PATH}snapshots"
chown meilisearch:meilisearch "${MEILISEARCH_DATA_PATH}" -R
chmod ugo= "${MEILISEARCH_DATA_PATH}" -R
chmod u=rwX,go=rX "${MEILISEARCH_DATA_PATH}" -R


fxTitle "Downloading the config file..."
curl -o /etc/meilisearch.toml \
  https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/meilisearch/config.toml

fxTitle "Generating the masterkey..."
MEILISEARCH_MASTERKEY="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"

fxTitle "Replacing the placeholder in the config file..."
sed -i "s|##CHANGE_ME##|${MEILISEARCH_MASTERKEY}|g" /etc/meilisearch.toml
fxMessage "$(cat /etc/meilisearch.toml)"


fxTitle "Downloading the service file..."
curl -o /etc/systemd/system/meilisearch.service \
  https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/meilisearch/service.txt


fxTitle "Service management..."
systemctl enable meilisearch
systemctl start meilisearch
systemctl --no-pager status meilisearch


fxTitle "Testing..."
sleep 5
curl -s http://127.0.0.1:7700/health | jq


fxTitle "Listing API keys..."
curl -s -H "Authorization: Bearer ${MEILISEARCH_MASTERKEY}" \
  "http://localhost:7700/keys" | jq

fxWarning "Take note of it and use it in your application MEILISEARCH_API_KEY"


fxEndFooter
