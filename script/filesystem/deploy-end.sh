if [ -f "${SCRIPT_DIR}notify.sh" ]; then
  bash ${SCRIPT_DIR}notify.sh "deploy-end" "$1"
fi

removeLock "${LOCKFILE}"

source ${SCRIPT_DIR}/script_end.sh
