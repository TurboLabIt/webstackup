fxHeader "👀 ${APP_NAME} run dev"
devOnlyCheck

if [ ! -z "${NODEJS_VER}" ]; then

  fxTitle "🤹 Setting node.js version..."
  sudo n "${NODEJS_VER}"
fi

fxTitle "🤹 node.js version in use"
sudo -u $EXPECTED_USER -H node --version

if [ -z "$NODE_PORT" ]; then
  NODE_PORT=5173
fi

fxTitle "🤹 NODE_PORT"
echo "$NODE_PORT"

fxTitle "💿 npm install..."
echo "y" | sudo -u $EXPECTED_USER -H npm install

fxTitle "👮 Fixing permissions..."
sudo chmod ug+x node_modules/.bin -R

fxTitle "🏃 Running..."
echo "y" | sudo -u $EXPECTED_USER -H npm run dev -- --port $NODE_PORT
