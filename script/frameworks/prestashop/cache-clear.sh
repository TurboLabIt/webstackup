#!/usr/bin/env bash
## Standard PrestaShop cache-clearing routine by WEBSTACKUP
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=prestashop` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/cache-clear.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzcache` directly

fxHeader "🛒🧹 PrestaShop cache-clear"

showPHPVer

if [ -z "${WEBROOT_DIR}" ] || [ ! -d "${WEBROOT_DIR}" ]; then
  fxCatastrophicError "📁 WEBROOT_DIR not set"
fi

if [ "$1" = "fast" ]; then
  FAST_CACHE_CLEAR=1
fi


cd "$WEBROOT_DIR"


fxTitle "Setting var/logs permissions..."
sudo chmod ugo= "${WEBROOT_DIR}var/logs" -R
sudo chmod ugo=rwX "${WEBROOT_DIR}var/logs" -R


fxTitle "Temporary open permissions on cache..."
sudo chmod ugo=rwx "${WEBROOT_DIR}var/cache" -R


fxTitle "Refresh the list of installed PHP versions know to Symfony..."
wsuSymfony local:php:refresh
wsuSymfony local:php:list


## composer install
if [ -z "${FAST_CACHE_CLEAR}" ]; then
  wsuComposer install
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then

  fxTitle "⚙️ Stopping services..."
  sudo nginx -t && sudo service nginx stop
  sudo service ${PHP_FPM} restart
fi

## remove cache/*
sudo find "${WEBROOT_DIR}var/cache/" -mindepth 1 -maxdepth 1 ! -name ".gitignore" ! -name "CACHEDIR.TAG" -exec rm -rf {} +


fxTitle "🌊 Symfony cache:clear..."
sudo -u www-data -H XDEBUG_MODE=off symfony console cache:clear


fxTitle "🌊 PrestaShop cache:clear..."
sudo -u www-data -H XDEBUG_MODE=off symfony console prestashop:cache:clear


## migrate
if [ -z "${FAST_CACHE_CLEAR}" ] && [ -f "${SCRIPT_DIR}migrate.sh" ]; then

  bash "${SCRIPT_DIR}migrate.sh"

elif [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "🚚 Migrating..."
  wsuSymfony console doctrine:migrations:migrate --no-interaction
fi


fxTitle "👮 Setting final permissions on var/cache..."
sudo chown webstackup:www-data "${WEBROOT_DIR}var/cache" -R
sudo chmod ugo= "${WEBROOT_DIR}var/cache" -R
sudo chmod ug=rwX,o= "${WEBROOT_DIR}var/cache" -R
sudo chmod g+s "${WEBROOT_DIR}var/cache"


## build
if [ -z "${FAST_CACHE_CLEAR}" ] && [ -f "${SCRIPT_DIR}build.sh" ]; then
  bash "${SCRIPT_DIR}build.sh"
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then

  fxTitle "⚙️ Restarting services..."
  sudo service ${PHP_FPM} restart
  sudo nginx -t && sudo service nginx start
fi


if [ "$APP_ENV" = "dev" ]; then

  fxTitle "chown dev..."
  sudo chown $(logname):www-data "${WEBROOT_DIR}" -R
  sudo chmod ugo= "${WEBROOT_DIR}" -R
  sudo chmod ugo=rwx "${WEBROOT_DIR}" -R
fi


fxTitle "🧹 Cleaning..."
sudo rm -rf /tmp/symfony
sudo rm -rf /tmp/prestashop-cache


fxTitle "Final status..."
ls -ld "${WEBROOT_DIR}var"
ls -la "${WEBROOT_DIR}var/cache"
