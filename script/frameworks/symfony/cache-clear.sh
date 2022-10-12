#!/usr/bin/env bash
## Standard Symfony cache-clearing routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/symfony/cache-clear-starter.sh && sudo chmod u=rwx,go=rx script/cache-clear.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzcache` directly

SCRIPT_NAME=symfony-cache-clear
fxHeader "📐🧹 Symfony cache-clear"

showPHPVer

if [ -z "${PROJECT_DIR}" ] || [ ! -d "${PROJECT_DIR}" ]; then
  fxCatastrophicError "📁 PROJECT_DIR not set"
fi

if [ "$1" = "fast" ]; then
  FAST_CACHE_CLEAR=1
fi

cd "$PROJECT_DIR"

if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Stopping services.."
  sudo nginx -t && sudo service nginx stop && sudo service ${PHP_FPM} stop

  fxTitle "🧹 Removing Symfony cache folder..."
  sudo rm -rf "${PROJECT_DIR}var/cache"

else

  fxTitle "📐 Symfony cache folder NOT removed (fast mode)"

fi

fxTitle "🌊 Symfony cache:clear..."
wsuSymfony console cache:clear

if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Restarting services.."
  sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart

else

  fxTitle "🌊 PHP OPcache clear..."
  wsuOpcacheClear

fi
