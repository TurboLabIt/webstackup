#!/usr/bin/env bash
### MEILISEARCH TOOLS GUI by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/meilisearch/zzmeili.sh

TITLE="Meilisearch management GUI"
OPTIONS=(
  1 "🧨  Wipe the data folder (preserve API keys)"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1) sudo bash ${WEBSTACKUP_SCRIPT_DIR}meilisearch/wipe.sh;;
esac
