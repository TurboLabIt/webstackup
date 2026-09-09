fxHeader "👀 ${APP_NAME} watch"

## the watch command is framework-specific: frameworks/<framework>/watch.sh defines wsuNodeWatch() and then sources this file
if ! declare -F wsuNodeWatch > /dev/null; then
  fxCatastrophicError "node.js/watch.sh: wsuNodeWatch() is undefined. Define it in frameworks/${PROJECT_FRAMEWORK}/watch.sh before sourcing this script"
fi

source "${WEBSTACKUP_SCRIPT_DIR}node.js/node_script_begin.sh"

fxTitle "💿 npm install..."
echo "y" | ${NPM_CMD} install

fxTitle "👀 watching..."
wsuNodeWatch
