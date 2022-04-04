if [ "${APP_ENV}" != 'prod' ] && [ "${APP_ENV}" != 'staging' ]; then
  printTitle "Common deploy ops can't run in this APP_ENV (##${APP_ENV}##)"
  return
fi

if [ -z "${PROJECT_DIR}" ] || [ -z "${SCRIPT_DIR}" ]; then
  printTitle "Common deploy ops can't run with either PROJECT_DIR or SCRIPT_DIR undefined"
  printMessage "PROJECT_DIR: ##${PROJECT_DIR}##"
  printMessage "SCRIPT_DIR: ##${SCRIPT_DIR}##"
  return
fi

## pulling and merging
if [ ! -z "${EXPECTED_USER}" ]; then
  printTitle "⏬ Git pulling..."
  #sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" reset --hard
  sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" pull
  sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" gc --aggressive
fi

if [ ! -z "${EXPECTED_USER}" ] && [ ! -z "${PHP_CLI}" } && [ -f "${PROJECT_DIR}composer.json" ]; then
  printTitle "📦 Composer install..."
  sudo -u $EXPECTED_USER -H ${PHP_CLI} /usr/local/bin/composer install --working-dir "${PROJECT_DIR}"
fi

## zzdeploy global command
if [ -f "${SCRIPT_DIR}deploy.sh" ] && [ ! -f "/usr/local/bin/zzdeploy" ] ; then
  printTitle "⚙️ Linking zzdeploy..."
  sudo ln -s "${SCRIPT_DIR}deploy.sh" "/usr/local/bin/zzdeploy"
fi

## zzcache global command
if [ -f "${SCRIPT_DIR}cache-flush.sh" ] && [ ! -f "/usr/local/bin/zzcache" ] ; then
  printTitle "⚙️ Linking zzcache..."
  sudo ln -s "${SCRIPT_DIR}cache-flush.sh" "/usr/local/bin/zzcache"
fi

## zztest global command
if [ -f "${SCRIPT_DIR}test-runner.sh" ] && [ ! -f "/usr/local/bin/zztest" ] ; then
  printTitle "⚙️ Linking zztest..."
  sudo ln -s "${SCRIPT_DIR}test_runner.sh" "/usr/local/bin/zztest"
fi

## zzcd bookmarks
if [ -f "${SCRIPT_DIR}zzcd_bookmarks.sh" ]; then
  printTitle "📂 Linking zzcd config..."
  sudo rm -f "/etc/turbolab.it/zzcd_bookmarks.sh"
  sudo ln -s "${SCRIPT_DIR}zzcd_bookmarks.sh" "/etc/turbolab.it/zzcd_bookmarks.sh"
fi

## shared cron
if [ ! -f "${PROJECT_DIR}config/custom/cron" ] && [ ! -z "${APP_NAME}" ]; then
  printTitle "⏲️ Copying shared cron file..."
  sudo cp "${PROJECT_DIR}config/custom/cron" "/etc/cron.d/${APP_NAME}"
  sudo service cron restart
fi

## env-specific cron file
if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/cron" ] && [ ! -z "${APP_NAME}" ]; then
  printTitle "⏲️ Copying ${APP_ENV} cron file..."
  sudo cp "${PROJECT_DIR}config/custom/cron" "/etc/cron.d/${APP_NAME}_${APP_ENV}"
  sudo service cron restart
fi

## php-custom for php-fpm
if [ ! -z "${PHP_VER}" ] && [ ! -z "${APP_NAME}" ] && [ -f "${PROJECT_DIR}config/custom/php-custom.ini" ] && [ ! -f "/etc/php/${PHP_VER}/fpm/conf.d/90-${APP_NAME}.ini" ]; then
  printTitle "📜 Linking php-custom from fpm..."
  sudo ln -s "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/fpm/conf.d/90-${APP_NAME}.ini"
fi

## php-custom (specific) for php-fpm
if [ ! -z "${PHP_VER}" ] && [ ! -z "${APP_NAME}" ] && [ -f "${PROJECT_DIR}config/custom/php-custom-fpm.ini" ] && [ ! -f "/etc/php/${PHP_VER}/fpm/conf.d/95-${APP_NAME}-fpm.ini" ]; then
  printTitle "📜 Linking php-custom-fpm..."
  sudo ln -s "${PROJECT_DIR}config/custom/php-custom-fpm.ini" "/etc/php/${PHP_VER}/fpm/conf.d/95-${APP_NAME}-fpm.ini"
fi

## php-custom for php-cli
if [ ! -z "${PHP_VER}" ] && [ ! -z "${APP_NAME}" ] && [ -f "${PROJECT_DIR}config/custom/php-custom.ini" ] && [ ! -f "/etc/php/${PHP_VER}/cli/conf.d/90-${APP_NAME}.ini" ]; then
  printTitle "📜 Linking php-custom from cli..."
  sudo ln -s "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/cli/conf.d/90-${APP_NAME}.ini"
fi

## php-custom (specific) for php-cli
if [ ! -z "${PHP_VER}" ] && [ ! -z "${APP_NAME}" ] && [ -f "${PROJECT_DIR}config/custom/php-custom-cli.ini" ] && [ ! -f "/etc/php/${PHP_VER}/cli/conf.d/95-${APP_NAME}-cli.ini" ]; then
  printTitle "📜 Linking php-custom-cli..."
  sudo ln -s "${PROJECT_DIR}config/custom/php-custom-cli.ini" "/etc/php/${PHP_VER}/cli/conf.d/95-${APP_NAME}-cli.ini"
fi

## nginx server{}
if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf" ] && [ ! -z "${APP_NAME}" ] && [ ! -f "/etc/nginx/conf.d/${APP_NAME}" ]; then
  printTitle "🌎 Linking nginx server {}..."
  sudo ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf" "/etc/nginx/conf.d/${APP_NAME}"
fi

## autodeploy
if [ "$APP_ENV" == "staging" ] && [ ! -z "${WEBROOT_DIR}" ] && [ ! -f "${WEBROOT_DIR}autodeploy-async.php" ]; then
  printTitle "Linking autodeploy..."
  ln -s "${WEBSTACKUP_SCRIPT_DIR}php/autodeploy-async.php" "${WEBROOT_DIR}"
fi

## php restart
if [ ! -z "${PHP_VER}" ]; then
  printTitle "🔃 Restarting PHP..."
  sudo service php${PHP_VER}-fpm restart
fi

## nginx restart
printTitle "🔃 Conditional nginx restart..."
sudo nginx -t && service nginx restart
