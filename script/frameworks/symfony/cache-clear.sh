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


fxTitle "Temporary open permissions on cache..."
sudo chmod ugo=rwx "${PROJECT_DIR}var/cache" -R


## composer install
if [ -z "${FAST_CACHE_CLEAR}" ]; then
  wsuComposer install
fi


## dump-env
if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then
  wsuComposer dump-env ${APP_ENV}
fi


## migrate
if [ -z "${FAST_CACHE_CLEAR}" ] && [ -f "${SCRIPT_DIR}migrate.sh" ]; then

  bash "${SCRIPT_DIR}migrate.sh"

elif [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "🚚 Migrating..."
  wsuSymfony console doctrine:migrations:migrate --no-interaction
fi


if [ -z "${FAST_CACHE_CLEAR}" ]; then

  #fxTitle "⚙️ Stopping services.."
  #sudo nginx -t && sudo service nginx stop && sudo service ${PHP_FPM} stop

  ## https://github.com/symfony/monolog-bundle/issues/288
  fxTitle "🧹 Removing the Symfony cache folder..."
  sudo rm -rf "${PROJECT_DIR}var/cache"

  fxTitle "☀ Creating the Symfony cache folder anew..."
  sudo mkdir -p "${PROJECT_DIR}var/cache"

else

  fxTitle "📐 Symfony cache folder NOT removed (fast mode)"
fi


fxTitle "Temporary open permissions on cache..."
sudo chmod ugo=rwx "${PROJECT_DIR}var/cache" -R


fxTitle "🌊 Symfony cache:clear..."
sudo -u www-data -H symfony console cache:clear --no-optional-warmers
sudo -u www-data -H symfony console cache:warmup 
#&> "${PROJECT_DIR}var/log/cache-warmer.log" &


fxTitle "Resetting permissions..."
sudo chown webstackup:www-data "${PROJECT_DIR}var" -R
sudo chmod ugo= "${PROJECT_DIR}var" -R
sudo chmod ug=rwX,o=rX "${PROJECT_DIR}var" -R


fxTitle "Final status..."
ls -latrh "${PROJECT_DIR}var/cache"


if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Restarting services.."
  #sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart

else

  fxTitle "🌊 PHP OPcache clear..."
  wsuOpcacheClear
fi
