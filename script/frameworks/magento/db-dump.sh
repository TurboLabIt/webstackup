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
wsuMkDbDumpDir

cd "${MAGENTO_DIR}"

DB_DUMP_FILE_PATH=${DB_DUMP_DIR}db_${APP_NAME}-${APP_ENV}_db-dump-sh.sql.gz

wsuN98MageRun db:dump "${MAGENTO_DB_DUMP_FILE_PATH}" --compression=gzip \
  --strip="@aggregated @dotmailer @ee_changelog @oauth @replica @search @stripped @temp"
  
fxMessage "##$DB_DUMP_FILE_PATH##"
