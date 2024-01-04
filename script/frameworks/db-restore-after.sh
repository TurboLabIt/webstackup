if [ "${SKIP_POST_RESTORE_QUERY}" != "1" ]; then

  bash "${SCRIPT_DIR}cache-clear.sh"

else

  fxTitle "⚙️ Running db-post-restore SQL queries..."
  fxInfo "SKIP_POST_RESTORE_QUERY is set, skipping"
fi
