fxHeader "👀 ${APP_NAME} run dev"
devOnlyCheck

source "${WEBSTACKUP_SCRIPT_DIR}node.js/node_script_begin.sh"

fxTitle "🏃 Running..."
echo "y" | sudo -u $EXPECTED_USER -H npm run dev -- --port $NODE_PORT
