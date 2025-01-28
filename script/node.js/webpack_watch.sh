fxHeader "👀 ${APP_NAME} watch"
devOnly


if [ ! -z "${NODEJS_VER}" ]; then

  fxTitle "🤹 Setting node.js version..."
  sudo n 20
fi


fxTitle "🤹 node.js version in use"
sudo -u $EXPECTED_USER -H node --version


fxTitle "💿 yarn install..."
echo "y" | sudo -u $EXPECTED_USER -H yarn install


fxTitle "🔨 watching with yarn..."
if grep -q '"watch":' package.json; then

  fxInfo "yarn watch"
  sudo -u $EXPECTED_USER -H yarn watch
  
else

  fxCatastrophicError "yarn watch is not defined in package.json"
fi
