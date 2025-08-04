if [ "${PROJECT_FRAMEWORK}" == "wordpress" ] && [ -f "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/package.json" ]; then

  fxTitle "📰 Custom WordPress theme detected!"
  fxInfo "Switching to ##${WEBROOT_DIR}wp-content/themes/${APP_NAME}##"
  cd "${WEBROOT_DIR}wp-content/themes/${APP_NAME}"
fi


if [ ! -z "${NODEJS_VER}" ]; then

  fxTitle "🤹 Setting node.js version..."
  sudo n 20
fi

fxTitle "🤹 node.js version in use"
sudo -u $EXPECTED_USER -H node --version


fxTitle "💿 yarn install..."
echo "y" | sudo -u $EXPECTED_USER -H yarn install
