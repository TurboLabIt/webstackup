#!/usr/bin/env bash
## Standard Pimcore cache-clearing routine by WEBSTACKUP

fxHeader "♾🧹 Pimcore cache-clear"

showPHPVer

if [ -z "${PROJECT_DIR}" ] || [ ! -d "${PROJECT_DIR}" ]; then
  fxCatastrophicError "📁 PROJECT_DIR not set"
fi

if [ "$1" = "fast" ]; then
  FAST_CACHE_CLEAR=1
fi

cd "$PROJECT_DIR"

if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Stopping services.."
  sudo nginx -t && sudo service nginx stop && sudo service ${PHP_FPM} stop

  fxTitle "🧹 Removing Pimcore cache folder..."
  sudo rm -rf "${PROJECT_DIR}var/cache"
  
  fxTitle "🚚 Migrating..."
  wsuSymfony console doctrine:migrations:migrate --no-interaction

else

  fxTitle "📐 Symfony cache folder NOT removed (fast mode)"
fi


fxTitle "↗ Pushing current PHP classes to database..."
# https://pimcore.com/docs/pimcore/current/Development_Documentation/Deployment/Deployment_Tools.html
wsuSymfony console pimcore:deployment:classes-rebuild --create-classes


fxTitle "🌊 Pimcore cache:clear..."
# https://pimcore.com/docs/pimcore/current/Development_Documentation/Deployment/Deployment_Tools.html#page_Potentially-useful-commands
wsuSymfony console pimcore:cache:clear
wsuSymfony console cache:clear


if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Restarting services.."
  sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart

else

  fxTitle "🌊 PHP OPcache clear..."
  wsuOpcacheClear
fi
