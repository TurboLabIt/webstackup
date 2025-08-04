fxHeader "🏗 ${APP_NAME} build"

source "${WEBSTACKUP_SCRIPT_DIR}node.js/webpack_script_begin.sh"


fxTitle "👮 Fixing permissions..."
sudo chmod ug+x node_modules/.bin -R
sudo chmod ug+x node_modules/webpack* -R
sudo chmod ug+x node_modules/@webpack-cli -R


fxTitle "🔨 building with yarn..."
if grep -q '"dist":' package.json; then

  fxInfo "yarn dist"
  sudo -u $EXPECTED_USER -H yarn dist

elif grep -q '"build":' package.json; then

  fxInfo "yarn build"
  sudo -u $EXPECTED_USER -H yarn build
  
else

  fxInfo "yarn webpack"
  sudo -u $EXPECTED_USER -H yarn webpack --mode production
fi
