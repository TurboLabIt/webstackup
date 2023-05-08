if [ "${SKIP_POST_RESTORE_QUERY}" = "1" ]; then

  fxTitle "⚙️ Running db-post-restore SQL queries..."
  fxInfo "SKIP_POST_RESTORE_QUERY is set, skipping"
  return
fi


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


bash "${SCRIPT_DIR}cache-clear.sh"
