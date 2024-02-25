## Startup procedure to build a Symfony Bundle
# https://github.com/TurboLabIt/webstackup/blob/master/script/php/symfony-bundle-builder.sh
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/symfony-bundle-builder.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/symfony-bundle-builder.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

SCRIPT_TITLE="📦 Symfony Bundle Builder"

if [ -f /usr/local/turbolab.it/webstackup/script/php/symfony-bundle-script-begin.sh ]; then
  source /usr/local/turbolab.it/webstackup/script/php/symfony-bundle-script-begin.sh
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php/symfony-bundle-script-begin.sh)
fi


if [ ! -z ${REQ_CHECK_FAILURE} ]; then
  fxCatastrophicError "Some required tools are missing!"
fi



fxTitle "Looking for composer.json..."
if [ ! -f "${PROJECT_DIR}composer.json" ]; then

  fxInfo "##${PROJECT_DIR}composer.json## not found. Downloading..."
  curl -O https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/symfony-bundle-builder/composer.json

else

  fxOK "composer.json found, nothing to do"
fi


symfony local:php:refresh
symfony composer update
rm -rf composer.lock


fxTitle "Looking for a .gitignore..."
if [ ! -f "${PROJECT_DIR}.gitignore" ]; then

  fxInfo "##${PROJECT_DIR}.gitignore## not found. Downloading..."
  curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore

else

  fxOK ".gitignore found, nothing to do"
fi


fxTitle "Building the bundle structure..."
## 📚 https://symfony.com/doc/current/bundles.html#bundle-directory-structure
for DIR_NAME in assets config public templates translations scripts; do

  if [ ! -d "${PROJECT_DIR}${DIR_NAME}" ]; then

    fxInfo "##${PROJECT_DIR}${DIR_NAME}## folder not found. Creating..."
    mkdir "${PROJECT_DIR}${DIR_NAME}"

  else

    fxOK "${DIR_NAME} found, nothing to do"
  fi

done


fxTitle "Checking the main Bundle file..."
if [ ! -f "${PROJECT_DIR}*Bundle.php" ]; then

  fxInfo "No Bundle file found. Downloading..."
  curl -O https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/symfony-bundle-builder/MyVendorNameMyPackageNameBundle.php
  
else

  fxOK "src found, nothing to do"
fi


fxTitle "Checking config/..."
if [ ! -f "${PROJECT_DIR}config/services.yaml" ]; then

  fxInfo "##${PROJECT_DIR}config/services.yaml## not found. Downloading..."
  cd config
  curl -O https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/symfony-bundle-builder/config/services.yaml
  cd ..
  
else

  fxOK "services.yaml found, nothing to do"
fi


fxTitle "Checking src/DependencyInjection/..."
if [ ! -d "${PROJECT_DIR}src/DependencyInjection" ]; then

  fxInfo "##${PROJECT_DIR}src/DependencyInjection## folder not found. Creating..."
  mkdir -p src/Service
  mkdir -p src/DependencyInjection
  cd src/DependencyInjection
  curl -O https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/symfony-bundle-builder/src/DependencyInjection/MyVendorNameMyPackageNameExtension.php
  cd ../..

else

  fxOK "src/DependencyInjection found, nothing to do"
fi


fxTitle "Checking scripts/symfony-bundle-tester.sh..."
if [ ! -f "${PROJECT_DIR}scripts/symfony-bundle-tester.sh" ]; then

  fxInfo "##${PROJECT_DIR}scripts/symfony-bundle-tester.sh## not found. Downloading..."
  cd scripts
  curl -O https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/symfony-bundle-builder/scripts/symfony-bundle-tester.sh
  cd ..

else

  fxOK "symfony-bundle-tester.sh found, nothing to do"
fi


## dependencies
fxTitle "Looking for Symfony Framework..."
if [ ! -d "${PROJECT_DIR}vendor/symfony/framework-bundle" ]; then

  fxInfo "Symfony Framework not found. Composer req it now..."
  symfony composer require symfony/framework-bundle --dev

else

  fxOK "Symfony Framework is already installed"
fi

rm -rf composer.lock


fxEndFooter

