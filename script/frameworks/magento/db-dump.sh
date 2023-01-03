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

## create $DB_DUMP_DIR
wsuMkAutogenDir

cd "${MAGENTO_DIR}"

wsuN98MageRun db:dump "${DB_DUMP_DIR}db_${APP_NAME}-${APP_ENV}_db-dump-sh.sql.gz --compression=gzip \
  --strip="@aggregated @dotmailer @ee_changelog @oauth @replica @search @stripped @temp"
