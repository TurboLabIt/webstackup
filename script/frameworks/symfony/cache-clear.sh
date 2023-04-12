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
  CACHE_CLEAR_PARAMS=--no-optional-warmers
fi


cd "$PROJECT_DIR"


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
  fxTitle "🧹 Removing Symfony cache folder..."
  sudo rm -rf "${PROJECT_DIR}var/cache/dev" "${PROJECT_DIR}var/cache/staging" "${PROJECT_DIR}var/cache/prod"

else

  fxTitle "📐 Symfony cache folder NOT removed (fast mode)"
fi


fxTitle "🌊 Symfony cache:clear..."
wsuSymfony console cache:clear ${CACHE_CLEAR_PARAMS}


if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Restarting services.."
  #sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart

else

  fxTitle "🌊 PHP OPcache clear..."
  wsuOpcacheClear
fi
