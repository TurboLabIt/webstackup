#!/usr/bin/env bash
## Standard Magento database dump loader routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/db-load.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/db-load.sh && sudo chmod u=rwx,go=rx scripts/db-load.sh
#
# 1. You should now git commit your copy

fxHeader "🧙🗄️ Magento database loader"

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

echo "🗄️ DB_DUMP_FILE_PATH:    ##${DB_DUMP_FILE_PATH}##"
echo "⚙️ SKIP_POST_LOAD_QUERY:  ##${SKIP_POST_LOAD_QUERY}#"

fxEnvNotProd
showPHPVer

cd "${MAGENTO_DIR}"

wsuN98MageRun db:import "${DB_DUMP_FILE_PATH}" --drop --compression=gzip

source "${WEBSTACKUP_SCRIPT_DIR}frameworks/db-load-after.sh"
