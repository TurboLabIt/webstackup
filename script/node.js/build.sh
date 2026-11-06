fxHeader "🏗️ ${APP_NAME} build"

source "${WEBSTACKUP_SCRIPT_DIR}node.js/node_script_begin.sh"

fxTitle "💿 npm install..."
## no audit: it can take minutes (after every Strapi publish to npm, for example) and run.sh sources this file while the app is down
echo "y" | ${NPM_CMD} install --no-audit --no-fund

fxTitle "🏗️ npm build..."
echo "y" | ${NPM_CMD} run build
