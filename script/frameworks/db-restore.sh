## Framework-initiated database dump via zzmysqldump

fxHeader "🗄️ Database restore"

echo "🗄️ DB_DUMP_FILE_PATH:    ##${DB_DUMP_FILE_PATH}##"
echo "📛 MYSQL_DB_NAME:        ##${MYSQL_DB_NAME}##"
echo "⚙️ SKIP_POST_RESTORE_QUERY:  ##${SKIP_POST_RESTORE_QUERY}#"


fxTitle "Env check..."
fxOK "$APP_ENV"
if [ "$APP_ENV" == "prod" ]; then
  fxAskConfirmation "PROD env detected! Do you really want to restore the db IN PROD?"
fi

cd "${PROJECT_DIR}backup/db-dumps"

sudo zzmysqlimp "${DB_DUMP_FILE_PATH}" "${MYSQL_DB_NAME}"

source "${WEBSTACKUP_SCRIPT_DIR}frameworks/db-restore-after.sh"
