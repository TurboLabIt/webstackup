#!/usr/bin/env bash
## Standard Magento db-dump routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/db-dump.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/db-dump.sh && sudo chmod u=rwx,go=rx scripts/db-dump.sh
#
# 1. You should now git commit your copy

fxHeader "🧙🗄️ Magento database dump"

showPHPVer

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

cd "${MAGENTO_DIR}"
wsuMageN98 db:dump ../backup/db-dump_${APP_NAME}_${APP_ENV}.sql.gz --compression=gzip --strip="@stripped @emails @ee_changelog @search"
