#!/usr/bin/env bash
### MEILISEARCH STATUS CHECKER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/meilisearch/status.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/meilisearch/status.sh | sudo bash
#

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧬  Meilisearch status checker"
rootCheck


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


fxTitle "/health..."
curl -s http://127.0.0.1:7700/health | jq


fxTitle "Listing API keys..."
curl -s -H "Authorization: Bearer ${MEILISEARCH_MASTERKEY}" \
  "http://localhost:7700/keys" | jq


fxTitle "/stats..."
curl -s -H "Authorization: Bearer ${MEILISEARCH_MASTERKEY}" \
  "http://localhost:7700/stats" | jq


fxEndFooter
