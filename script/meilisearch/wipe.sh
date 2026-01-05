#!/usr/bin/env bash
### MEILISEARCH DATA WIPER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/meilisearch/wipe.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/meilisearch/wipe.sh | sudo bash
#

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧨 MEILISEARCH data wiper"
rootCheck
fxAskConfirmation
MEILISEARCH_DATA_PATH=/var/lib/meilisearch/


fxTitle "🔑 Extracting the master key..."
MEILISEARCH_MASTERKEY=$(
  grep '^[[:space:]]*master_key[[:space:]]*=' "/etc/meilisearch.toml" | \
  sed 's/^[[:space:]]*master_key[[:space:]]*=[[:space:]]*"\(.*\)"[[:space:]]*$/\1/' 
)


if [ -z "${MEILISEARCH_MASTERKEY}" ]; then
  fxCatastrophicError "Master key extraction failed"
fi


fxTitle "Installing prerequisites..."
if [ -z $(command -v jq) ]; then sudo apt update && sudo apt install jq -y; fi


fxTitle "🛑 Stopping the service..."
service meilisearch stop


fxTitle "🧨 Nuking the data folder..."
rm -rf "${MEILISEARCH_DATA_PATH}data"


fxTitle "📂 Current status..."
ls -l "${MEILISEARCH_DATA_PATH}"


fxTitle "🆕 Re-creating the data folder..."
mkdir -p "${MEILISEARCH_DATA_PATH}data"
chown meilisearch:meilisearch "${MEILISEARCH_DATA_PATH}data" -R
chmod ugo= "${MEILISEARCH_DATA_PATH}data" -R
chmod u=rwX,go=rX "${MEILISEARCH_DATA_PATH}data" -R


fxTitle "🏁 Starting the service...."
systemctl start meilisearch
systemctl --no-pager status meilisearch


fxTitle "Testing..."
sleep 5
curl -s http://127.0.0.1:7700/health | jq


fxTitle "Listing API keys..."
curl -s -H "Authorization: Bearer ${MEILISEARCH_MASTERKEY}" \
  "http://localhost:7700/keys" | jq


fxOK "System ready!"
fxWarning "You MUST re-generate your indexes NOW!"


fxEndFooter
