#!/usr/bin/env bash
## Standard Magento database dump restore routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/db-restore.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/db-restore.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

fxHeader "🧙🗄️ Magento database restore"

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

echo "🗄️ DB_DUMP_FILE_PATH:    ##${DB_DUMP_FILE_PATH}##"
echo "⚙️ SKIP_POST_RESTORE_QUERY:  ##${SKIP_POST_RESTORE_QUERY}#"

fxEnvNotProd
showPHPVer

cd "${MAGENTO_DIR}"


wsuN98MageRun db:import "${DB_DUMP_FILE_PATH}" --drop --compression=gzip


if [ "${SKIP_POST_RESTORE_QUERY}" != "1" ]; then

  fxTitle "⚙️ Running SQL query for staging..."
  SQL_STAGING=${PROJECT_DIR}config/custom/staging/db-post-restore.sql
  if [ -f "${SQL_STAGING}" ]; then
    wsuN98MageRun db:import "${SQL_STAGING}"
  else
    fxWarning "##$SQL_STAGING## not found, skipping"
  fi


  fxTitle "⚙️ Running SQL query for dev..."
  SQL_DEV=${PROJECT_DIR}config/custom/dev/db-post-restore.sql
  if [ "${APP_ENV}" = "dev" ] && [ ! -f "${SQL_DEV}" ]; then
    fxWarning "##$SQL_DEV## not found, skipping"
  elif [ "${APP_ENV}" = "dev" ] && [ -f "${SQL_DEV}" ]; then
    wsuN98MageRun db:import "${SQL_DEV}"
  else
    fxInfo "APP_ENV is ##${APP_ENV}##, skipping"
  fi

else

  fxTitle "⚙️ Running db-post-restore SQL queries..."
  fxInfo "SKIP_POST_RESTORE_QUERY is set, skipping"
fi

source "${WEBSTACKUP_SCRIPT_DIR}frameworks/db-restore-after.sh"
