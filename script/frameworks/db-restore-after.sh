fxTitle "⚙️ Running post-restore..."

if [ "${SKIP_POST_RESTORE_QUERY}" == "1" ]; then

  fxInfo "SKIP_POST_RESTORE_QUERY is set, skipping 🦘"

else

  if [ "${APP_ENV}" == "master" ] && [ -f "${PROJECT_DIR}config/custom/prod/db-post-restore.sql" ]; then

    mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" < "${PROJECT_DIR}config/custom/prod/db-post-restore.sql"

  elif [[ "${APP_ENV}" == "staging" || "${APP_ENV}" == "dev" ]] && [ -f "${PROJECT_DIR}config/custom/staging/db-post-restore.sql" ]; then

    mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" < "${PROJECT_DIR}config/custom/staging/db-post-restore.sql"

  fi


  if [ "${APP_ENV}" == "dev" ] && [ -f "${PROJECT_DIR}config/custom/dev/db-post-restore.sql" ]; then
    mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" < "${PROJECT_DIR}config/custom/dev/db-post-restore.sql"
  fi

  bash "${SCRIPT_DIR}cache-clear.sh"
fi
