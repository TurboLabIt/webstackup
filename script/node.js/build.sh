fxHeader "🏗️ ${APP_NAME} build"

source "${WEBSTACKUP_SCRIPT_DIR}node.js/node_script_begin.sh"

fxTitle "💿 npm install..."
echo "y" | ${NPM_CMD} install

fxTitle "🏗️ npm build..."
echo "y" | ${NPM_CMD} run build
