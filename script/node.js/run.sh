fxHeader "🚀 ${APP_NAME} run"

source "${WEBSTACKUP_SCRIPT_DIR}node.js/build.sh"

fxTitle "🏃 Starting the server..."
echo "y" | sudo -u $EXPECTED_USER -H PORT=$NODE_PORT npm start
