fxHeader "🚀 ${APP_NAME} run"

source "${WEBSTACKUP_SCRIPT_DIR}node.js/build.sh"

fxTitle "🏃 Starting the server..."
sudo -u $EXPECTED_USER -H PORT=$NODE_PORT NODE_ENV=$NODE_ENV node server.js build/server/index.js
