#!/usr/bin/env bash
## Standard Magento build routine by WEBSTACKUP
#
# How to:
#
# 1. Set your theme and language(s) in your project `script_begin.sh`:
#  MAGENTO_STATIC_CONTENT_DEPLOY="MyCompany/myTheme en_US it_IT fr_FR de_DE es_ES"
#
# 1. set `PROJECT_FRAMEWORK=magento` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/build.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

fxHeader "🧙👷 Magento builder"

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

cd "$MAGENTO_DIR"


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
wsuMage setup:di:compile
wsuMage setup:static-content:deploy --area adminhtml ${MAGENTO_STATIC_CONTENT_DEPLOY_ADMIN} --jobs 8 -f
wsuMage setup:static-content:deploy -t ${MAGENTO_STATIC_CONTENT_DEPLOY} --jobs 8 -f
wsuMage cache:flush
