fxHeader "🚀 ${APP_NAME} run"

## the start command is framework-specific: frameworks/<framework>/run.sh defines wsuNodeRun() and then sources this file
if ! declare -F wsuNodeRun > /dev/null; then
  fxCatastrophicError "node.js/run.sh: wsuNodeRun() is undefined. Define it in frameworks/${PROJECT_FRAMEWORK}/run.sh before sourcing this script"
fi

source "${WEBSTACKUP_SCRIPT_DIR}node.js/build.sh"

NODE_RUN_LOG="${PROJECT_DIR}var/log/node-run.log"
fxTitle "📜 Log file"
echo "${NODE_RUN_LOG}"
sudo touch "${NODE_RUN_LOG}"
sudo chown www-data:www-data "${NODE_RUN_LOG}"
sudo chmod 664 "${NODE_RUN_LOG}"

fxTitle "🏃 Starting the server..."
## stdout+stderr go to both the console and the log file.
## tee -a appends, so logrotate's copytruncate works without leaving NUL gaps.
## tee -i ignores Ctrl+C: node must be the one to stop (the signal is relayed to it by sudo);
## tee then exits by itself when node closes the pipe, after flushing the last lines.
wsuNodeRun 2>&1 | tee -ai "${NODE_RUN_LOG}"
