#!/usr/bin/env bash
## Standard Symfony cache-clearing routine by WEBSTACKUP
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=symfony` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/cache-clear.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzcache` directly

fxHeader "📐🧹 Symfony cache-clear"

showPHPVer

if [ -z "${PROJECT_DIR}" ] || [ ! -d "${PROJECT_DIR}" ]; then
  fxCatastrophicError "📁 PROJECT_DIR not set"
fi

if [ "$1" = "fast" ]; then
  FAST_CACHE_CLEAR=1
fi


cd "$PROJECT_DIR"


fxTitle "Setting var/log permissions..."
sudo mkdir -p "${PROJECT_DIR}var/log"
sudo chmod ugo= "${PROJECT_DIR}var/log" -R
sudo chmod ugo=rwX "${PROJECT_DIR}var/log" -R


fxTitle "Temporary open permissions on cache..."
sudo mkdir -p "${PROJECT_DIR}var/cache"
sudo chmod ugo=rwX "${PROJECT_DIR}var/cache" -R
sudo mkdir -p "${PROJECT_DIR}var/share"
sudo chmod ugo=rwX "${PROJECT_DIR}var/share" -R


fxTitle "Refresh the list of installed PHP versions know to Symfony..."
wsuSymfony local:php:refresh
wsuSymfony local:php:list


## composer install
if [ -z "${FAST_CACHE_CLEAR}" ]; then
  wsuComposer install
fi


## dump-env
if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then
  wsuComposer dump-env ${APP_ENV}
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then

  fxTitle "⚙️ Stopping services..."

  if [ -z "$(command -v nginx)" ]; then
    fxWarning "Nginx not installed"
  else
    sudo nginx -t && sudo service nginx stop
  fi

  if [ -z "$(command -v php-fpm${PHP_VER})" ] && [ ! -f "/etc/init.d/${PHP_FPM}" ]; then
    fxWarning "php-fpm not installed"
  else
    sudo service ${PHP_FPM} restart
  fi
fi


## https://github.com/symfony/monolog-bundle/issues/288
fxTitle "🧹 Removing the Symfony cache folder..."
sudo rm -rf "${PROJECT_DIR}var/cache"
sudo rm -rf "${PROJECT_DIR}var/share/pools"
sudo rm -rf "${PROJECT_DIR}var/share/http_cache"


fxTitle "☀ Creating the Symfony cache folders anew..."
sudo mkdir -p "${PROJECT_DIR}var/cache"
sudo chmod ugo=rwX "${PROJECT_DIR}var/cache" -R


fxTitle "🌊 Symfony cache:clear..."
sudo -u www-data -H XDEBUG_MODE=off symfony console cache:clear --no-optional-warmers
sudo -u www-data -H XDEBUG_MODE=off symfony console cache:pool:clear --all


## migrate
if [ -z "${FAST_CACHE_CLEAR}" ] && [ -f "${SCRIPT_DIR}migrate.sh" ]; then

  bash "${SCRIPT_DIR}migrate.sh"

elif [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "🚚 Migrating..."

  if [ ! -d "${PROJECT_DIR}vendor/doctrine/doctrine-migrations-bundle" ]; then
    fxWarning "Doctrine Migrations not installed: nothing to migrate"
  else
    wsuSymfony console doctrine:migrations:migrate --no-interaction
  fi
fi


## build
if [ -z "${FAST_CACHE_CLEAR}" ] && [ -f "${SCRIPT_DIR}build.sh" ]; then
  bash "${SCRIPT_DIR}build.sh"
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then

  fxTitle "⚙️ Restarting services..."

  if [ -z "$(command -v php-fpm${PHP_VER})" ] && [ ! -f "/etc/init.d/${PHP_FPM}" ]; then
    fxWarning "php-fpm not installed"
  else
    sudo service ${PHP_FPM} restart
  fi

  if [ -z "$(command -v nginx)" ]; then
    fxWarning "Nginx not installed"
  else
    sudo nginx -t && sudo service nginx start
  fi
fi


fxTitle "🔥 Cache warmup..."
sudo -u www-data -H XDEBUG_MODE=off symfony console cache:warmup
#&> "${PROJECT_DIR}var/log/cache-warmer.log" &


fxTitle "👮 Setting final permissions..."
sudo chown webstackup:www-data "${PROJECT_DIR}var/cache" -R
sudo chmod ug=rwX,o=rX "${PROJECT_DIR}var/cache" -R
sudo chmod g+s "${PROJECT_DIR}var/cache"
sudo chown webstackup:www-data "${PROJECT_DIR}var/share" -R
sudo chmod ug=rwX,o=rX "${PROJECT_DIR}var/share" -R
sudo chmod g+s "${PROJECT_DIR}var/share"


if [ "$APP_ENV" = "dev" ]; then

  fxTitle "chown dev..."
  sudo chown $(logname):www-data "${PROJECT_DIR}" -R
  sudo chmod ugo= "${PROJECT_DIR}" -R
  sudo chmod ugo=rwx "${PROJECT_DIR}" -R
fi


fxTitle "🧹 Cleaning..."
sudo rm -rf /tmp/symfony-cache


fxTitle "Final status..."
ls -ld "${PROJECT_DIR}var"
ls -la "${PROJECT_DIR}var/cache"
ls -la "${PROJECT_DIR}var/share"


if [ -n "${CLOUDFLARE_API_KEY}" ] && [ -n "${CLOUDFLARE_ZONE_ID}" ]; then
  fxCloudFlareCacheClear "${CLOUDFLARE_API_KEY}" "${CLOUDFLARE_ZONE_ID}"
fi
