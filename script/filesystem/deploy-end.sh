if [ "$APP_ENV" = "prod" ] && [ -f ${SCRIPT_DIR}deploy_notify.sh ]; then
  bash ${SCRIPT_DIR}notify.sh "🎉 Deploy completed for ${APP_NAME} on PRODUCTION ($HOSTNAME)" "$1"
fi

fxTitle "Removing lockfile ${LOCKFILE}..."
removeLock ${LOCKFILE}

source ${SCRIPT_DIR}/script_end.sh
