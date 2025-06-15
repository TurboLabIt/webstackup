## Run phpunit tests of your package by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/blob/master/script/php/test-runner-package.sh
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/test-runner.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/test-runner.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

cd "$PROJECT_DIR"

if [ ! -d "${PROJECT_DIR}tests" ]; then
  fxWarning "Directory ##${PROJECT_DIR}tests## not found, skipping tests"
  return 127
fi

showPHPVer

wsuComposer install


fxTitle "⚙️ Installing webdrivers..."
if [ -f "${PROJECT_DIR}vendor/bin/bdi" ]; then

  sudo killall -s KILL chromedriver
  rm -rf "${PROJECT_DIR}drivers"
  XDEBUG_MODE=off ${PHP_CLI} ${PROJECT_DIR}vendor/bin/bdi detect drivers

else

  fxInfo "No webdrivers required"
fi


fxTitle "👢 Bootstrap"
BOOTSTRAP_FILE=${PROJECT_DIR}tests/bootstrap.php
fxInfo "phpunit bootstrap file set to ##${BOOTSTRAP_FILE}##"

if [ ! -f "${BOOTSTRAP_FILE}" ]; then
  fxInfo "Bootstrap file non found. Downloading..."
  curl -Lo "${BOOTSTRAP_FILE}" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/phpunit-bootstrap.php
fi


fxTitle "🚕 Migrating/upgrading phpunit config..."
XDEBUG_MODE=off ${PHP_CLI} ./vendor/bin/phpunit \
  --bootstrap "${BOOTSTRAP_FILE}" \
  --migrate-configuration


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
if [ "${WSU_TEST_RUNNER_PARALLEL}" != 0 ]; then
  PHPUNIT_EXEC=./vendor/bin/paratest
else
  PHPUNIT_EXEC=./vendor/bin/phpunit
fi

SYMFONY_DEPRECATIONS_HELPER=disabled ${PHP_CLI} ${PHPUNIT_EXEC} \
  --bootstrap "${BOOTSTRAP_FILE}" \
  --display-warnings \
  --stop-on-failure $@ \
  tests

PHPUNIT_RESULT=$?
echo ""

if [ "${PHPUNIT_RESULT}" = 0 ]; then

  fxMessage "🎉 TEST RAN SUCCESSFULLY!"
  fxCountdown 3
  echo ""

  ## Example: https://github.com/TurboLabIt/php-symfony-basecommand/blob/main/tests/RunTestCommand.php
  fxTitle "Running the test command..."
  TEST_COMMAND_PATH=${PROJECT_DIR}tests/RunTestCommand.php
  if [ -f "${TEST_COMMAND_PATH}" ]; then
    ${PHP_CLI} tests/RunTestCommand.php
  else
    fxInfo "##$TEST_COMMAND_PATH## not found, skipping"
  fi

  wsuPlayOKSound

else

  fxMessage "🛑 TEST FAILED | phpunit returned ${PHPUNIT_RESULT}"
  wsuPlayKOSound
fi
