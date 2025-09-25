#!/usr/bin/env bash
### MEILISEARCH DATA WIPER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/meilisearch/wipe.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/meilisearch/wipe.sh | sudo bash
#

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧨 MEILISEARCH data wiper"
rootCheck

MEILISEARCH_DATA_PATH=/var/lib/meilisearch/


fxAskConfirmation


fxTitle "Installing prerequisites..."
apt update -qq
apt install jq -y


fxTitle "🛑 Stopping the service..."
service meilisearch stop


fxTitle "🗝️ Preserving the API keys..."
mv "${MEILISEARCH_DATA_PATH}data/auth" "${MEILISEARCH_DATA_PATH}backup_auth"


fxTitle "🧨 Nuking the data folder..."
rm -rf "${MEILISEARCH_DATA_PATH}data"


fxTitle "📂 Current status..."
ls -l "${MEILISEARCH_DATA_PATH}"


fxTitle "🆕 Re-creating the data folder..."
mkdir -p "${MEILISEARCH_DATA_PATH}data"
chown meilisearch:meilisearch "${MEILISEARCH_DATA_PATH}data" -R
chmod ugo= "${MEILISEARCH_DATA_PATH}data" -R
chmod u=rwX,go=rX "${MEILISEARCH_DATA_PATH}data" -R


fxTitle "🔃 Restoring the API keys..."
mv "${MEILISEARCH_DATA_PATH}backup_auth" "${MEILISEARCH_DATA_PATH}data/auth"


fxTitle "🏁 Starting the service...."
systemctl start meilisearch
systemctl --no-pager status meilisearch


fxTitle "Testing..."
sleep 5
curl -s http://127.0.0.1:7700/health | jq


fxOK "System ready!"
fxWarning "You MUST re-generate your indexes NOW!"


fxEndFooter
