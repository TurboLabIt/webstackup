fxHeader "🏗 ${APP_NAME} build"

source "${WEBSTACKUP_SCRIPT_DIR}node.js/webpack_script_begin.sh"


fxTitle "🔨 building with yarn..."
if grep -q '"dist":' package.json; then

  fxInfo "yarn dist"
  $YARN_CMD dist || fxCatastrophicError "yarn dist failed"

elif grep -q '"build":' package.json; then

  fxInfo "yarn build"
  $YARN_CMD build || fxCatastrophicError "yarn build failed"
  
else

  fxInfo "yarn webpack"
  $YARN_CMD webpack --mode production || fxCatastrophicError "yarn webpack failed"
fi
