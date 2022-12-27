#!/usr/bin/env bash
## Standard Magento cache-clearing routine by WEBSTACKUP
#
# How to:
#
# 1. Set your theme and language(s) in your project `script_begin.sh`:
#  MAGENTO_STATIC_CONTENT_DEPLOY="MyCompany/myTheme en_US it_IT fr_FR de_DE es_ES"
#
# 1. set `PROJECT_FRAMEWORK=magento` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/cache-clear.sh && sudo chmod u=rwx,go=rx scripts/cache-clear.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzcache` directly

fxHeader "🧙🧹 Magento cache-clear"

showPHPVer

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

if [ "$1" = "fast" ]; then
  FAST_CACHE_CLEAR=1
fi

cd "$MAGENTO_DIR"

if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then

  fxTitle "⚙️ Entering maintenance mode..."
  wsuMage maintenance:enable

  fxTitle "Enable merge and minify..."
  wsuMage config:set dev/js/merge_files 1
  wsuMage config:set dev/js/enable_js_bundling 0
  wsuMage config:set dev/js/minify_files 1
  wsuMage config:set dev/css/merge_css_files 1
  wsuMage config:set dev/css/minify_files 1
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" = "dev" ]; then

  fxTitle "🧑‍💻 Setting developer mode..."
  sudo rm -rf "${MAGENTO_DIR}generated/metadata/"*
  wsuMage deploy:mode:set developer --skip-compilation
  
  fxTitle "🛍️ Current mode..."
  wsuMage deploy:mode:show

  fxTitle "🧑‍💻 Change admin settings..."
  wsuMage config:set admin/security/session_lifetime 31536000
  
  fxTitle "Enable merge and minify..."
  wsuMage config:set dev/js/merge_files 0
  wsuMage config:set dev/js/enable_js_bundling 0
  wsuMage config:set dev/js/minify_files 0
  wsuMage config:set dev/css/merge_css_files 0
  wsuMage config:set dev/css/minify_files 0

elif [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "🛍️ Setting PRODUCTION mode..."
  wsuMage deploy:mode:set production --skip-compilation
  
  fxTitle "🛍️ Current mode..."
  wsuMage deploy:mode:show

  fxTitle "🛍️ Change admin settings..."
  wsuMage config:set admin/security/session_lifetime 86400
fi

wsuMage config:set admin/security/password_lifetime ''

## main.WARNING: Session size of 336381 exceeded allowed session max size of 256000
# https://github.com/magento/magento2/issues/33748 (increase to 0.5 MB)
wsuMage config:set system/security/max_session_size_admin 512000

if [ -z "${FAST_CACHE_CLEAR}" ]; then

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

  ## legacy implementation
  #fxTitle "🧙🏗️ static-content:deploy admin"
  #wsuMage setup:static-content:deploy --area adminhtml it_IT en_US -f

  #if [ ! -z "${MAGENTO_STATIC_CONTENT_DEPLOY}" ]; then

    #fxTitle "🧙🏗️ static-content:deploy -t ${MAGENTO_STATIC_CONTENT_DEPLOY}"
    #wsuMage setup:static-content:deploy -t ${MAGENTO_STATIC_CONTENT_DEPLOY} -f

  #fi
  ## ############################

  fxTitle "🧙🏗️ static-content:deploy"
  wsuMage setup:static-content:deploy --jobs 4 -s standard -f

else

  fxTitle "🧙🏗️ di:compile and static-content:deploy skipped (fast mode)"
fi

fxTitle "🌊 Magento cache:flush..."
wsuMage cache:flush

fxTitle "🐧 Setting the owner (async)..."
sudo chown ${EXPECTED_USER}:www-data . -R &

fxTitle "🐧 Setting permissions (async)..."
sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + &
sudo find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + &

if [ -z "${FAST_CACHE_CLEAR}" ]  && [ "${APP_ENV}" != "dev" ]; then

  fxTitle "⚙️ Exiting maintenance mode..."
  wsuMage maintenance:disable

else

  fxTitle "🌊 PHP OPcache clear..."
  wsuOpcacheClear
fi
