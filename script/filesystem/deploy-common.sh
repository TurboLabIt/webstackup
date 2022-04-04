if [ "${APP_ENV}" != 'prod' ] && [ "${APP_ENV}" != 'staging' ] ; then
  printTitle "Common deploy ops can't run in this APP_ENV (##${APP_ENV}##)"
  return
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
