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

fxTitle "👀 build..."
sudo -u $EXPECTED_USER -H yarn dist
