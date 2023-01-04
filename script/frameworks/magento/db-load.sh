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


if [ "${SKIP_POST_LOAD_QUERY}" != 1 ]; then

  fxTitle "⚙️ Running SQL query for staging..."
  SQL_STAGING=${PROJECT_DIR}config/custom/staging/db-post-load.sql
  if [ -f "${SQL_STAGING}" ]; then

    wsuN98MageRun db:import "${SQL_STAGING}"

  else

    fxWarning "##$SQL_STAGING## not found, skipping"
  fi


  fxTitle "⚙️ Running SQL query for dev..."
  SQL_DEV=${PROJECT_DIR}config/custom/dev/db-post-load.sql
  if [ "${APP_ENV}" = "dev" ] && [ ! -f "${SQL_DEV}" ]; then

    fxWarning "##$SQL_DEV## not found, skipping"

  elif [ "${APP_ENV}" = "dev" ] && [ -f "${SQL_DEV}" ]; then

    wsuN98MageRun db:import "${SQL_DEV}"

  else

    fxInfo "APP_ENV is ##${APP_ENV}##, skipping"
  fi

else 

  fxTitle "⚙️ Running db-post-load SQL queries..."
  fxInfo "SKIP_POST_LOAD_QUERY is set, skipping"
fi

bash "${SCRIPT_DIR}cache-clear.sh"
