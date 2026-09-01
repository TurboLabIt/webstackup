fxHeader "👀 ${APP_NAME} watch"

source "${WEBSTACKUP_SCRIPT_DIR}node.js/node_script_begin.sh"

fxTitle "💿 npm install..."
echo "y" | ${NPM_CMD} install

fxTitle "👀 watching..."
echo "y" | sudo -u $EXPECTED_USER -H npm run dev -- --port $NODE_PORT
