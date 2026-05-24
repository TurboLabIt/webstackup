fxHeader "👀 ${APP_NAME} watch"
devOnlyCheck

source "${WEBSTACKUP_SCRIPT_DIR}node.js/webpack_script_begin.sh"


fxTitle "🔨 watching with yarn..."
if grep -q '"watch":' package.json; then

  fxInfo "yarn watch"
  $YARN_CMD watch
  
else

  fxInfo "yarn webpack"
  $YARN_CMD webpack --watch --mode development
fi
