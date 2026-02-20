fxHeader "👀 ${APP_NAME} run prod"

source "${WEBSTACKUP_SCRIPT_DIR}node.js/react-router_script_begin.sh"

fxTitle "🏃 Running..."
echo "y" | sudo -u $EXPECTED_USER -H npm run build -- --port $NODE_PORT
