fxTitle "⚙️ Running post-restore..."

if [ "${SKIP_POST_RESTORE_QUERY}" == "1" ]; then

  fxInfo "SKIP_POST_RESTORE_QUERY is set, skipping 🦘"

elif [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/db-post-restore.sql" ]; then

  sudo bash -c "source /etc/turbolab.it/mysql.conf && \
    mysql -u \"\$MYSQL_USER\" -p\"\$MYSQL_PASSWORD\" -h \"\$MYSQL_HOST\" \"${MYSQL_DB_NAME}\" \
      < \"${PROJECT_DIR}config/custom/${APP_ENV}/db-post-restore.sql\""

  bash "${SCRIPT_DIR}cache-clear.sh"

else

  fxWarning "${APP_ENV}/db-post-restore.sql not found"
fi
