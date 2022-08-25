#!/usr/bin/env bash
## Standard Magento reindexing routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo script/reindex.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/magento/reindex-starter.sh && sudo chmod u=rwx,go=rx script/reindex.sh
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

if [ "$1" = "fast" ]; then
  FAST_REINDEX=1
fi

cd "$MAGENTO_DIR"

#if [ -z "${FAST_REINDEX}" ]; then

  #fxTitle "⚙️ Entering maintenance mode..."
  #wsuMage maintenance:enable 
#fi

fxTitle "Applying catalog rules.."


fxTitle "Reindexing..."
wsuMage indexer:reindex


fxTitle "🌊 Magento cache:flush..."
wsuMage cache:flush


#if [ -z "${FAST_REINDEX}" ]; then

  #fxTitle "⚙️ Exiting maintenance mode..."
  #wsuMage maintenance:disable 

#else

  #fxTitle "🌊 PHP OPcache clear..."
  #wsuOpcacheClear

#fi
