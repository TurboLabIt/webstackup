fxHeader "🏗 ${APP_NAME} build"

fxTitle "🤹 Setting node.js version..."
sudo n 20
sudo -u $EXPECTED_USER -H node --version

fxTitle "💿 yarn install..."
sudo -u $EXPECTED_USER -H yarn install

fxTitle "📦 Webpack..."
sudo -u $EXPECTED_USER -H yarn webpack

fxTitle "👀 build..."
sudo -u $EXPECTED_USER -H yarn build
