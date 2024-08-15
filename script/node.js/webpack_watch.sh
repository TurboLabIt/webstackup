fxHeader "🏗 ${APP_NAME} watch"

fxTitle "🤹 Setting node.js version..."
sudo n 20
sudo -u $EXPECTED_USER -H node --version

fxTitle "🔄 Setting Yarn version to stable..."
sudo -u $EXPECTED_USER -H yarn set version stable

fxTitle "💿 yarn install..."
sudo -u $EXPECTED_USER -H yarn install

fxTitle "📦 Webpack..."
sudo -u $EXPECTED_USER -H yarn webpack

fxTitle "👀 Watch..."
sudo -u $EXPECTED_USER -H yarn watch
