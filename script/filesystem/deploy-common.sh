if [ "${APP_ENV}" != 'prod' ] && [ "${APP_ENV}" != 'staging' ]; then
  catastrophicError "Common deploy ops can't run in this APP_ENV (##${APP_ENV}##)"
  return
fi

if [ -z "${APP_NAME}" ] || [ -z "${EXPECTED_USER}" ] || [ -z "${PHP_VER}" ] ||  [ -z "${PROJECT_DIR}" ] || [ -z "${SCRIPT_DIR}" ]; then
  catastrophicError "Common deploy ops can't run with these variables undefined:
  
  APP_NAME:    ##${APP_NAME}##
  APP_NAME:    ##${EXPECTED_USER}##
  PHP_VER:     ##${PHP_VER}##
  PROJECT_DIR: ##${PROJECT_DIR}##
  SCRIPT_DIR:  ##${SCRIPT_DIR}##"
  return
fi

if [ -z "${PROJECT_DIR}" ] || [ -z "${SCRIPT_DIR}" ]; then
  catastrophicError "Common deploy ops can't run with either PROJECT_DIR or SCRIPT_DIR undefined"
  return
fi

## pulling and merging
printTitle "⏬ Git pulling..."
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" reset --hard
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" pull
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" gc --aggressive
  
## composer
if [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${PROJECT_DIR}composer.json" ]; then

  COMPOSER_JSON_FULLPATH=${PROJECT_DIR}composer.json

elif [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${WEBROOT_DIR}composer.json" ]; then

  COMPOSER_JSON_FULLPATH=${WEBROOT_DIR}composer.json
fi

if [ ! -z "${COMPOSER_JSON_FULLPATH}" ]; then
  printTitle "📦 Composer install from ##${COMPOSER_JSON_FULLPATH}##..."
  sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" /usr/bin/php${PHP_VER} /usr/local/bin/composer install --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})" --no-dev
fi

## zzdeploy global command
if [ -f "${SCRIPT_DIR}deploy.sh" ] && [ ! -f "/usr/local/bin/zzdeploy" ] ; then
  printTitle "⚙️ Linking zzdeploy..."
  ln -s "${SCRIPT_DIR}deploy.sh" "/usr/local/bin/zzdeploy"
fi

## zzcache global command
if [ -f "${SCRIPT_DIR}cache-flush.sh" ] && [ ! -f "/usr/local/bin/zzcache" ] ; then
  printTitle "⚙️ Linking zzcache..."
  ln -s "${SCRIPT_DIR}cache-flush.sh" "/usr/local/bin/zzcache"
fi

## zztest global command
if [ -f "${SCRIPT_DIR}test-runner.sh" ] && [ ! -f "/usr/local/bin/zztest" ] ; then
  printTitle "⚙️ Linking zztest..."
  ln -s "${SCRIPT_DIR}test_runner.sh" "/usr/local/bin/zztest"
fi

## zzcd bookmarks
if [ -f "${SCRIPT_DIR}zzcd_bookmarks.sh" ]; then
  printTitle "📂 Linking zzcd config..."
  rm -f "/etc/turbolab.it/zzcd_bookmarks.sh"
  ln -s "${SCRIPT_DIR}zzcd_bookmarks.sh" "/etc/turbolab.it/zzcd_bookmarks.sh"
fi

## cron
if [ -f "${PROJECT_DIR}config/custom/cron" ]; then
  printTitle "⏲️ Copying shared cron file..."
  cp "${PROJECT_DIR}config/custom/cron" "/etc/cron.d/${APP_NAME}"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/cron" ]; then
  printTitle "⏲️ Copying ${APP_ENV} cron file..."
  cp "${PROJECT_DIR}config/custom/cron" "/etc/cron.d/${APP_NAME}_${APP_ENV}"
fi

printTitle "🔃️ Restarting cron..."
echo "/etc/cron.d/"
ls -la "/etc/cron.d/"
service cron restart

## php-custom for php-fpm
if [ -f "${PROJECT_DIR}config/custom/php-custom.ini" ] && [ ! -f "/etc/php/${PHP_VER}/fpm/conf.d/90-${APP_NAME}.ini" ]; then
  printTitle "📜 Linking php-custom from fpm..."
  ln -s "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/fpm/conf.d/90-${APP_NAME}.ini"
fi

## php-custom (specific) for php-fpm
if [ -f "${PROJECT_DIR}config/custom/php-custom-fpm.ini" ] && [ ! -f "/etc/php/${PHP_VER}/fpm/conf.d/95-${APP_NAME}-fpm.ini" ]; then
  printTitle "📜 Linking php-custom-fpm..."
  ln -s "${PROJECT_DIR}config/custom/php-custom-fpm.ini" "/etc/php/${PHP_VER}/fpm/conf.d/95-${APP_NAME}-fpm.ini"
fi

## php-custom for php-cli
if [ -f "${PROJECT_DIR}config/custom/php-custom.ini" ] && [ ! -f "/etc/php/${PHP_VER}/cli/conf.d/90-${APP_NAME}.ini" ]; then
  printTitle "📜 Linking php-custom from cli..."
  ln -s "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/cli/conf.d/90-${APP_NAME}.ini"
fi

## php-custom (specific) for php-cli
if [ -f "${PROJECT_DIR}config/custom/php-custom-cli.ini" ] && [ ! -f "/etc/php/${PHP_VER}/cli/conf.d/95-${APP_NAME}-cli.ini" ]; then
  printTitle "📜 Linking php-custom-cli..."
  ln -s "${PROJECT_DIR}config/custom/php-custom-cli.ini" "/etc/php/${PHP_VER}/cli/conf.d/95-${APP_NAME}-cli.ini"
fi

printTitle "🔃 Restarting PHP..."
service php${PHP_VER}-fpm restart
echo "/etc/php/${PHP_VER}/fpm/conf.d/"
ls -la "/etc/php/${PHP_VER}/fpm/conf.d/" | grep -v '10-\|15-\|20-'
echo ""
echo "/etc/php/${PHP_VER}/cli/conf.d/"
ls -la "/etc/php/${PHP_VER}/cli/conf.d/" | grep -v '10-\|15-\|20-'

## logrotate
if [ -f "${PROJECT_DIR}config/custom/logrotate.conf" ] && [ ! -f "/etc/logrotate.d/${APP_NAME}.conf" ]; then
  printTitle "📄 Linking custom logrotate config..."
  ln -s "${PROJECT_DIR}config/custom/logrotate.conf" "/etc/logrotate.d/${APP_NAME}.conf"
fi

printTitle "🔃️ Restarting logrotate..."
echo "/etc/logrotate.d"
ls -la "/etc/logrotate.d"
service logrotate restart

## nginx server{}
if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf" ] && [ ! -f "/etc/nginx/conf.d/${APP_NAME}" ]; then
  printTitle "🌎 Linking nginx server {}..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf" "/etc/nginx/conf.d/${APP_NAME}"
fi

printTitle "🔃 Conditional nginx restart..."
echo "/etc/nginx/conf.d"
ls -la "/etc/nginx/conf.d"
nginx -t && service nginx restart

## autodeploy
if [ "$APP_ENV" == "staging" ] && [ ! -f "${WEBROOT_DIR}autodeploy-async.php" ]; then
  printTitle "Linking autodeploy..."
  ln -s "${WEBSTACKUP_SCRIPT_DIR}php/autodeploy-async.php" "${WEBROOT_DIR}"
fi
