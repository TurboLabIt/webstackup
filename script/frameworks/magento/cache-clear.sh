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
#   curl -Lo scripts/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/cache-clear.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzcache` directly

fxHeader "🧙🧹 Magento cache-clear"

## kill the whole script on Ctrl+C
trap "exit" INT

showPHPVer

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

cd "$MAGENTO_DIR"


if [ "$1" = "fast" ]; then
  FAST_CACHE_CLEAR=1
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then

  ## Entering maintenance mode
  wsuMage maintenance:enable

  ## Enable merge and minify
  wsuMage config:set dev/js/merge_files 1
  wsuMage config:set dev/js/enable_js_bundling 0
  wsuMage config:set dev/js/minify_files 1
  wsuMage config:set dev/css/merge_css_files 1
  wsuMage config:set dev/css/minify_files 1
fi


if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "Restoring the standard, unoptimized composer autoload files..."
  rm -f "${MAGENTO_DIR}vendor/composer/autoload_*.php"
  wsuComposer dump-autoload
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" = "dev" ]; then

  ## Setting developer mode
  sudo rm -rf "${MAGENTO_DIR}generated/metadata/"*
  wsuMage deploy:mode:set developer --skip-compilation
  wsuMage deploy:mode:show

  ## Extending session life
  wsuMage config:set admin/security/session_lifetime 31536000

  ## Disable merge and minify
  wsuMage config:set dev/js/merge_files 0
  wsuMage config:set dev/js/enable_js_bundling 0
  wsuMage config:set dev/js/minify_files 0
  wsuMage config:set dev/css/merge_css_files 0
  wsuMage config:set dev/css/minify_files 0

elif [ -z "${FAST_CACHE_CLEAR}" ]; then

  ## Setting PRODUCTION mode
  wsuMage deploy:mode:set production --skip-compilation
  wsuMage deploy:mode:show

  ## Extending session life
  wsuMage config:set admin/security/session_lifetime 86400
fi


if [ -z "${FAST_CACHE_CLEAR}" ]; then

  ## Passwords should never expire
  wsuMage config:set admin/security/password_lifetime ''

  ## main.WARNING: Session size of 336381 exceeded allowed session max size of 256000
  # https://github.com/magento/magento2/issues/33748 (increase to 0.5 MB)
  wsuMage config:set system/security/max_session_size_admin 512000


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
  wsuMage setup:upgrade

  fxTitle "Disabling module(s)..."
  if [ ! -z "${MAGENTO_MODULE_DISABLE}" ]; then

    ## explode string to array
    readarray -d ' ' -t  MAGENTO_MODULE_DISABLE_ARRAY <<< "$MAGENTO_MODULE_DISABLE"

    for MOD_TO_DISABLE in "${MAGENTO_MODULE_DISABLE_ARRAY[@]}"; do

      ## trim the last element (?!?)
      MOD_TO_DISABLE=$(echo "${MOD_TO_DISABLE}")
      if [ ! -z "${MOD_TO_DISABLE}" ]; then
        wsuMage module:disable --clear-static-content "${MOD_TO_DISABLE}"
      fi

    done

  else

    fxWarning "No modules to disable defined"
  fi


  wsuMage setup:di:compile
  wsuMage setup:static-content:deploy --area adminhtml ${MAGENTO_STATIC_CONTENT_DEPLOY_ADMIN} --jobs 8 -f
  wsuMage setup:static-content:deploy -t ${MAGENTO_STATIC_CONTENT_DEPLOY} --jobs 8 -f

else

  fxInfo "Build phase skipped (fast mode)"
fi


wsuMage cache:flush


fxTitle "🐧 Setting permissions..."
sudo -b find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + > /dev/null 2>&1
sudo -b find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + > /dev/null 2>&1


## Generating composer dump-autoload classmap
if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "devvvvvv" ] && [ "${COMPOSER_SKIP_DUMP_AUTOLOAD}" != 1 ]; then

  ## https://getcomposer.org/doc/articles/autoloader-optimization.md
  wsuComposer dump-autoload --optimize
fi


if [ -z "${FAST_CACHE_CLEAR}" ]  && [ "${APP_ENV}" != "dev" ]; then
  wsuMage maintenance:disable
else
  wsuOpcacheClear
fi
