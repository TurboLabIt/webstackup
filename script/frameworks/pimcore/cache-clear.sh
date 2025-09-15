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

  wsuComposer install

  fxTitle "🧹 Removing Pimcore cache folder and set permissions..."
  sudo rm -rf "${PROJECT_DIR}var/cache"
  sudo mkdir -p "${PROJECT_DIR}var/cache"
  sudo chown ${EXPECTED_USER}:www-data "${PROJECT_DIR}var/cache" -R
  sudo chmod 777 "${PROJECT_DIR}var/cache" -R
  sudo chmod g+s "${PROJECT_DIR}var/cache"
  
  #if [ "${PIMCORE_ECOMMERECE_BUNDLE_ENABLED}" == "1" ]; then
  
    #fxTitle "🔎 --create-or-update-index-structure"
    #wsuSymfony console ecommerce:indexservice:bootstrap --create-or-update-index-structure
  #fi
  
  fxTitle "🐧 Setting permissions..."
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

else

  fxTitle "📐 Symfony cache folder NOT removed (fast mode)"
fi


fxTitle "🌊 Pimcore cache:clear..."
# https://pimcore.com/docs/pimcore/current/Development_Documentation/Deployment/Deployment_Tools.html#page_Potentially-useful-commands
sudo -u www-data -H symfony console pimcore:cache:clear
sudo -u www-data -H symfony console cache:clear


if [ -z "${FAST_CACHE_CLEAR}" ]; then

  fxTitle "⚙️ Restarting services.."
  sudo service ${PHP_FPM} restart
fi
