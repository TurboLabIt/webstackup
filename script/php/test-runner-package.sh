## Run phpunit tests of your package
#
# Usage example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/test-runner.sh

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


fxTitle "🔬 Checking input..."
if [ ! -z "$@" ]; then
  ADDITIONAL_PARAMS="--limit $@"
else
  fxInfo "No arguments"
fi


fxTitle "🤖 Testing with PHPUnit..."
${PHP_CLI} ./vendor/bin/phpunit \
  --bootstrap vendor/autoload.php \
  --cache-result-file=/tmp/.phpunit.${APP_NAME}.result.cache \
  --stop-on-failure $ADDITIONAL_PARAMS \
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

