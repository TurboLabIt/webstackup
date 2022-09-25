if [ "$APP_ENV" = "prod" ] && [ -f "${SCRIPT_DIR}notify.sh" ]; then
  bash ${SCRIPT_DIR}notify.sh "🎉 Deploy completed for ${APP_NAME} on PRODUCTION ($HOSTNAME)" "deploy" "$1"
fi

removeLock "${LOCKFILE}"

source ${SCRIPT_DIR}/script_end.sh
