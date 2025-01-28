fxHeader "🏗 ${APP_NAME} build"


if [ ! -z "${NODEJS_VER}" ]; then

  fxTitle "🤹 Setting node.js version..."
  sudo n 20
fi


fxTitle "🤹 node.js version in use"
sudo -u $EXPECTED_USER -H node --version


fxTitle "💿 yarn install..."
echo "y" | sudo -u $EXPECTED_USER -H yarn install


fxTitle "👮 Fixing permissions..."
sudo chmod ug+x node_modules/.bin -R
sudo chmod ug+x node_modules/webpack* -R
sudo chmod ug+x node_modules/@webpack-cli -R


fxTitle "🔨 build with yarn..."
if grep -q '"dist":' package.json; then

  fxInfo "yarn dist"
  sudo -u $EXPECTED_USER -H yarn dist

elif grep -q '"build":' package.json; then

  fxInfo "yarn build"
  sudo -u $EXPECTED_USER -H yarn build
  
else

  fxInfo "yarn webpack"
  sudo -u $EXPECTED_USER -H yarn webpack
fi
