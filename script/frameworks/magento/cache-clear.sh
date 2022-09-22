#!/usr/bin/env bash
## Standard Magento cache-clearing routine by WEBSTACKUP
#
# How to:
#
# 1. Set your theme and language(s) in your project `script_begin.sh`:
#  MAGENTO_STATIC_CONTENT_DEPLOY="MyCompany/myTheme en_US it_IT fr_FR de_DE es_ES"
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo script/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/magento/cache-clear-starter.sh && sudo chmod u=rwx,go=rx script/cache-clear.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzcache` directly

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

  fxTitle "⚙️ Entering maintenance mode..."
  wsuMage maintenance:enable 
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" = "dev" ]; then

  fxTitle "🧑‍💻 Setting developer mode..."
  rm -rf "${MAGENTO_DIR}generated/metadata/"*
  wsuMage deploy:mode:set developer --skip-compilation

  fxTitle "🧑‍💻 Change admin settings..."
  wsuMage config:set admin/security/session_lifetime 31536000

elif [ -z "${FAST_CACHE_CLEAR}" ] && [ ! -z "${APP_ENV}" ]; then

  fxTitle "🛍️ Setting PRODUCTION mode..."
  wsuMage deploy:mode:set production --skip-compilation

  fxTitle "🛍️ Change admin settings..."
  wsuMage config:set admin/security/session_lifetime 86400
fi

wsuMage config:set admin/security/password_lifetime ''

## main.WARNING: Session size of 336381 exceeded allowed session max size of 256000
# https://github.com/magento/magento2/issues/33748 (increase to 0.5 MB)
wsuMage config:set system/security/max_session_size_admin 512000

if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "🛍️ Current mode..."
  wsuMage deploy:mode:show

  fxTitle "🧹 Removing Magento folders..."
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

  wsuComposer install

  fxTitle "🧙🏗️ setup:upgrade..." 
  wsuMage setup:upgrade

  if [ ! -z "${MAGENTO_MODULE_DISABLE}" ]; then
    fxTitle "⚙️ Disabling modules ${MAGENTO_MODULE_DISABLE}..."
    wsuMage module:disable --clear-static-content ${MAGENTO_MODULE_DISABLE}
  fi

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

fxTitle "🌊 Magento cache:flush..."
wsuMage cache:flush

fxTitle "🐧 Setting the owner..."
sudo chown ${EXPECTED_USER}:www-data . -R

fxTitle "🐧 Setting permissions..."
sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
sudo find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +

if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Exiting maintenance mode..."
  wsuMage maintenance:disable 

else

  fxTitle "🌊 PHP OPcache clear..."
  wsuOpcacheClear
fi
