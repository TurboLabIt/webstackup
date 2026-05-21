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


source "${WEBSTACKUP_SCRIPT_DIR}node.js/node_script_begin.sh"


if [[ "$APP_ENV" == "dev" ]] && [[ "${NODEJS_SKIP_DEV_UPGRADE}" != "1" ]]; then

  fxTitle "(dev) Upgrading yarn to latest stable version..."
  sudo -u $EXPECTED_USER -H yarn set version stable

  fxTitle "(dev) Removing yarn.lock..."
  sudo rm -f "${PROJECT_DIR}yarn.lock"
fi

fxTitle "💿 yarn install..."
sudo -u $EXPECTED_USER -H yarn install


if [[ "$APP_ENV" == "dev" ]] && [[ "${NODEJS_SKIP_DEV_UPGRADE}" != "1" ]]; then

  fxTitle "(dev) npm-check-updates..."
  sudo -u $EXPECTED_USER -H yarn npm-check-updates -u

  fxTitle "(dev) Removing yarn.lock..."
  sudo rm -f "${PROJECT_DIR}yarn.lock"
fi

fxTitle "💿 yarn install..."
sudo -u $EXPECTED_USER -H yarn install


fxTitle "👮 Fixing permissions on ##node_modules/*webpack*##"
if ls node_modules/ | grep -q "webpack"; then
  sudo chmod ug+x node_modules/*webpack* -R
else
  fxInfo "Skipped (not found) 🦘"
fi
