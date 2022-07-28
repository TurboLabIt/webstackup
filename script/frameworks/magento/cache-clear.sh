#!/usr/bin/env bash
## Standard Magento cache-clearing routine by WEBSTACKUP
#
# How to:
# Copy this file to your project directory with:
#   curl -Lo script/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/magento/cache-clear-template.sh && sudo chmod u=rwx,go=rx script/cache-clear.sh
# You should then git commit your copy

SCRIPT_NAME=magento-cache-clear
fxHeader "🧙🧹 Magento cache-clear"

showPHPVer

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

if [ "$1" = "fast" ]; then
  FAST_CACHE_CLEAR=1
fi

cd "$MAGENTO_DIR"

if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Stopping services.."
  sudo nginx -t && sudo service nginx stop && sudo service ${PHP_FPM} stop

  fxTitle "🧹 Removing folders..."
  sudo rm -rf \
    "pub/static/frontend/" \
    "pub/static/adminhtml/" \
    "pub/static/_requirejs" \
    "pub/static/deployed_version.txt" \
    "var/cache/" \
    "var/page_cache/" \
    "generated/" \
    "var/view_preprocessed/" \
    "var/session/" \
    "var/di/"

  fxTitle "🧙🏗️ setup:di:compile..."
  wsuMage setup:di:compile

  fxTitle "🧙🏗️ static-content:deploy admin"
  wsuMage setup:static-content:deploy --area adminhtml it_IT en_US -f

  if [ ! -z "${MAGENTO_STATIC_CONTENT_DEPLOY}" ]; then
    fxTitle "🧙🏗️ static-content:deploy -t ${MAGENTO_STATIC_CONTENT_DEPLOY}"
    wsuMage setup:static-content:deploy -t ${MAGENTO_STATIC_CONTENT_DEPLOY} -f
    
  fi
  
else

  fxTitle "🧙🏗️ di:compile and static-content:deploy skipped (fast mode)"
  
fi

fxTitle "🌊 cache:flush..."
wsuMage cache:flush

fxTitle "🐧 Setting the owner..."
sudo chown ${EXPECTED_USER}:www-data . -R

fxTitle "🐧 Setting permissions..."
sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
sudo find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +

if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Restarting services.."
  sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart
  
fi
