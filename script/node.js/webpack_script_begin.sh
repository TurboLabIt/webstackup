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
  $YARN_CMD set version stable
fi

## the build must not run on a failed install: if it fails too, it still rewrites manifest.json, pointing at files it never emitted, and that can break the site
fxTitle "💿 yarn install..."
$YARN_CMD install || fxCatastrophicError "yarn install failed: stopping here, so the previous build stays in place"


if [ -z "${NPM_CHECK_UPDATES_COOLDOWN}" ]; then
  NPM_CHECK_UPDATES_COOLDOWN=5
fi

if [[ "$APP_ENV" == "dev" ]] && [[ "${NODEJS_SKIP_DEV_UPGRADE}" != "1" ]]; then

  fxTitle "(dev) npm-check-updates (cooldown: ${NPM_CHECK_UPDATES_COOLDOWN} days)..."
  $YARN_CMD dlx npm-check-updates -u --cooldown "${NPM_CHECK_UPDATES_COOLDOWN}"

  ## npm-check-updates moves only the direct dependencies, and yarn install keeps every locked version that still fits its range:
  ## with the old yarn.lock, the transitive ones would never move, security fixes included. Resolving from scratch still honors npmMinimalAgeGate
  fxTitle "(dev) 🧹 Removing yarn.lock, so that every dependency gets resolved again..."
  rm -f yarn.lock

  fxTitle "(dev) 💿 yarn install (updated packages, new yarn.lock)..."
  $YARN_CMD install || fxCatastrophicError "yarn install failed after npm-check-updates: stopping here, so the previous build stays in place. yarn.lock was removed: git checkout yarn.lock restores it"
fi


fxTitle "👮 Fixing permissions on ##node_modules/*webpack*##"
if [ -d "node_modules" ] && ls node_modules/ | grep -q "webpack"; then
  sudo chmod -R ug+x node_modules/*webpack*
else
  fxInfo "Skipped (not found) 🦘"
fi
