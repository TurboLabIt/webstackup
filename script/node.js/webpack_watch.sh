fxHeader "👀 ${APP_NAME} watch"
devOnlyCheck

source "${WEBSTACKUP_SCRIPT_DIR}node.js/webpack_script_begin.sh"


fxTitle "🔨 watching with yarn..."
if grep -q '"watch":' package.json; then

  fxInfo "yarn watch"
  sudo -u $EXPECTED_USER -H yarn watch
  
else

  fxInfo "yarn webpack"
  sudo -u $EXPECTED_USER -H yarn webpack --watch --mode development
fi
