## Run phpunit tests of your bundle by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/blob/master/script/php/test-runner-bundle.sh
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/test-runner-bundle.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/test-runner-bundle.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

## https://github.com/TurboLabIt/bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "🧪 Test Runner"


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


if [ ! -f "${PROJECT_DIR}.gitignore" ]; then
  fxInfo "##${PROJECT_DIR}.gitignore## not found  not found. Downloading..."
  curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore
fi


if [ ! -d "${PROJECT_DIR}tests" ]; then
  fxInfo "##${PROJECT_DIR}tests## folder not found. Creating..."
  mkdir tests
  curl -o "${PROJECT_DIR}tests/BundleTest.php" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/BundleTest.php
fi


if [ ! -d "${PROJECT_DIR}vendor/phpunit" ]; then
  symfony composer require phpunit/phpunit --dev
fi


symfony composer update
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
if [ "$APP_ENV" = dev ] && [ ! -z "$XDEBUG_PORT" ]; then

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
