## Startup procedure to build a Symfony Bundle
# https://github.com/TurboLabIt/webstackup/blob/master/script/php/test-runner-bundle.sh
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/symfony-bundle-builder.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/symfony-bundle-builder.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

## https://github.com/TurboLabIt/bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "📦 Symfony Bundle Builder"


if [ -f /usr/local/turbolab.it/webstackup/script/base.sh ]; then

  source /usr/local/turbolab.it/webstackup/script/base.sh
  
else

  ## Absolute path to this script, e.g. /home/user/bin/foo.sh
  SCRIPT_FULLPATH=$(readlink -f "$0")
  
  ## Absolute path this script is in, thus /home/user/bin
  SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/
  
  ##
  INITIAL_DIR=$(pwd)
  PROJECT_DIR=$(readlink -m "${SCRIPT_DIR}..")/
fi


cd "$PROJECT_DIR"

if [ ! -f "${PROJECT_DIR}composer.json" ]; then
  fxCatastrophicError "##${PROJECT_DIR}composer.json## not found"
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
for DIR_NAME in assets config public templates translations; do

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


fxTitle "Checking tests/..."
if [ ! -d "${PROJECT_DIR}tests" ]; then

  fxInfo "##${PROJECT_DIR}tests## folder not found. Creating..."
  mkdir tests
  cd tests
  curl -O https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/symfony-bundle-builder/tests/BundleTest.php
  cd ..

else

  fxOK "tests found, nothing to do"
fi


## dependencies
fxTitle "Looking for Symfony Framework..."
if [ ! -d "${PROJECT_DIR}vendor/symfony/framework-bundle" ]; then

  fxInfo "Symfony Framework not found. Composer req it now..."
  symfony composer require symfony/framework-bundle --dev

else

  fxOK "Symfony Framework is already installed"
fi


fxTitle "Looking for PHPUnit..."
if [ ! -d "${PROJECT_DIR}vendor/phpunit" ]; then

  fxInfo "PHPUnit not found. Composer req it now..."
  symfony composer require  phpunit/phpunit --dev

else

  fxOK "PHPUnit is already installed"
fi


rm -rf composer.lock


fxTitle "🔬 Checking input..."
if [ ! -z "$@" ]; then
  ADDITIONAL_PARAMS="$@"
else
  fxInfo "No arguments"
fi


fxTitle "👢 Bootstrap"
BOOTSTRAP_FILE=${PROJECT_DIR}tests/bootstrap.php
fxInfo "phpunit bootstrap file set to ##${BOOTSTRAP_FILE}##"

if [ ! -f "${BOOTSTRAP_FILE}" ]; then
  fxInfo "Bootstrap file non found. Downloading..."
  curl -Lo "${BOOTSTRAP_FILE}" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/phpunit-bootstrap.php
fi


fxTitle "🚕 Migrating/upgrading phpunit config..."
XDEBUG_MODE=off ./vendor/bin/phpunit \
  --bootstrap "${BOOTSTRAP_FILE}" --migrate-configuration


fxTitle "🐛 Xdebug"
if [ ! -z "$XDEBUG_PORT" ]; then

  export XDEBUG_CONFIG="remote_host=127.0.0.1 client_port=$XDEBUG_PORT"
  export XDEBUG_MODE="develop,debug"
  fxOK "Xdebug enabled to port ##$XDEBUG_PORT##. Good hunting!"
  fxInfo "To disable: export XDEBUG_PORT="

else

  export XDEBUG_MODE="off"
  fxInfo "Xdebug disabled (to enable: export XDEBUG_PORT=9999)"
fi


fxTitle "🤖 Testing with PHPUnit..."
SYMFONY_DEPRECATIONS_HELPER=disabled ./vendor/bin/phpunit \
  --bootstrap "${BOOTSTRAP_FILE}" \
  --display-warnings \
  --stop-on-failure $ADDITIONAL_PARAMS \
  tests


PHPUNIT_RESULT=$?
echo ""

if [ "${PHPUNIT_RESULT}" = 0 ]; then

  fxMessage "🎉 TEST RAN SUCCESSFULLY!"
  fxCountdown 3
  echo ""

else

  fxMessage "🛑 TEST FAILED | phpunit returned ${PHPUNIT_RESULT}"
fi

