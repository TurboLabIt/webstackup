#!/usr/bin/env bash
## Standard Magento reindexing routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/reindex.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/magento/reindex-starter.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzreindex` directly

SCRIPT_NAME=magento-reindex
fxHeader "📇 Magento reindex"

showPHPVer

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

cd "$MAGENTO_DIR"

if [ -z "$1" ]; then

  fxTitle "Reindexing all..."
  wsuMage indexer:reindex

elif [ "$1" = "fast" ]; then

  fxTitle "Fast reindexing..."
  fxMessage "My bad, fast reindex is note define yet :-("

else

  wsuMage indexer:reindex "$@"

fi

fxTitle "Status"
wsuMage indexer:status
