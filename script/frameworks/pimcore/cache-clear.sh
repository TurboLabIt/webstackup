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
  
  fxTitle "Set the recommended permissions"
  ## https://pimcore.com/docs/pimcore/current/Development_Documentation/Installation_and_Upgrade/System_Setup_and_Hosting/File_Permissions.html
  sudo -b chown -R www-data:www-data ${PROJECT_DIR}var/admin ${PROJECT_DIR}public/var > /dev/null 2>&1
  sudo -b chmod ug+x ${PROJECT_DIR}bin/* > /dev/null 2>&1
  sudo -b chmod 777 ${PROJECT_DIR}var ${PROJECT_DIR}public/var -R > /dev/null 2>&1
  
  if [ ! -f "${SCRIPT_DIR}migrate.sh" ]; then
  
    fxTitle "🚚 Migrating..."
    wsuSymfony console doctrine:migrations:migrate --no-interaction
    
  else
    
    bash "${SCRIPT_DIR}migrate.sh"
  fi
  
  fxTitle "↗ Pushing current PHP classes to database..."
  # https://pimcore.com/docs/pimcore/current/Development_Documentation/Deployment/Deployment_Tools.html
  wsuSymfony console pimcore:deployment:classes-rebuild --create-classes
  wsuSymfony console pimcore:deployment:classes-rebuild

  fxTitle "🌊 Pimcore cache:clear..."
  # https://pimcore.com/docs/pimcore/current/Development_Documentation/Deployment/Deployment_Tools.html#page_Potentially-useful-commands
  wsuSymfony console pimcore:cache:clear
  wsuSymfony console cache:clear

else

  fxTitle "📐 Symfony cache folder NOT removed (fast mode)"
fi



if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Restarting services.."
  sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart

else

  fxTitle "🌊 PHP OPcache clear..."
  wsuOpcacheClear
fi
