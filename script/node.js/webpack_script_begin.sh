fxTitle "Framework..."
echo "${PROJECT_FRAMEWORK}"


if [ "${PROJECT_FRAMEWORK}" == "wordpress" ] && [ -f "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/package.json" ]; then

  echo ""
  fxOK "Custom WordPress theme detected!"
  fxInfo "Switching to ##${WEBROOT_DIR}wp-content/themes/${APP_NAME}##"
  cd "${WEBROOT_DIR}wp-content/themes/${APP_NAME}"

elif [ "${PROJECT_FRAMEWORK}" == "wordpress" ]; then

  fxWarning "No package.json detected in ##${WEBROOT_DIR}wp-content/themes/${APP_NAME}##"
fi


if [ ! -f "package.json" ]; then
  fxCatastrophicError "package.json not found in ##$(pwd)##"
fi


if [ ! -z "${NODEJS_VER}" ]; then

  fxTitle "🤹 Setting node.js version..."
  sudo n 20
fi

fxTitle "🤹 node.js version in use"
sudo -u $EXPECTED_USER -H node --version


fxTitle "💿 yarn install..."
sudo -u $EXPECTED_USER -H COREPACK_ENABLE_DOWNLOAD_PROMPT=0 yarn install
