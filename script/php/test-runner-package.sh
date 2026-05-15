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


fxTitle "🧹 Test DB - reset Doctrine migration history"

# Ask Symfony's test-env Doctrine connection for the name of its DB.
# The regex matches only names that actually end in _test (word boundary),
# so an unmatched grep === a non-test DB === skip the drop.
TEST_DB_NAME=$(wsuSymfony console dbal:run-sql "SELECT DATABASE()" \
    --env=test --no-interaction --no-debug 2>/dev/null \
    | grep -v '^[[:space:]]*$' \
    | grep -v '^[[:space:]]*-' \
    | grep -v 'DATABASE' \
    | head -n1 \
    | xargs)

fxInfo "Database name is ##${TEST_DB_NAME}##"


if [[ "${TEST_DB_NAME}" == *_test ]]; then

  DO_DROP=1

  if [ "${WSU_TEST_SKIP_TEST_DB_TRUNCATION_WARNING}" != "1" ]; then

    fxWarning "About to DROP doctrine_migration_versions on ##${TEST_DB_NAME}##"
    fxWarning "Press y/Y to confirm, anything else to skip (set WSU_TEST_SKIP_TEST_DB_TRUNCATION_WARNING=1 to bypass this prompt)"
    read -p ">> " -n 1 -r < /dev/tty
    echo

    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
      DO_DROP=0
      fxInfo "Migration history reset declined by user 🦘"
    fi
  fi

  if [ "${DO_DROP}" = "1" ]; then

    fxInfo "DB name ends in _test - dropping doctrine_migration_versions"
    wsuSymfony console dbal:run-sql --env=test --no-interaction --no-debug \
      "DROP TABLE IF EXISTS doctrine_migration_versions"
    fxOK "Migration history cleared - every migration will run again"
  fi

else

  fxInfo "DB name does not end in _test, skipping migration history reset 🦘"
fi


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


if [ "${WSU_TEST_SKIP_MIGRATION}" != "1" ] && [ -f "${PROJECT_DIR}scripts/migrate.sh" ]; then

  bash "${PROJECT_DIR}scripts/migrate.sh"

else

  fxTitle "🚚 Database migration"
  fxInfo "Skipping migration - WSU_TEST_SKIP_MIGRATION=1 or missing ${PROJECT_DIR}scripts/migrate.sh 🦘"
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
  --stop-on-failure $@

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
    fxInfo "##$TEST_COMMAND_PATH## not found, skipping 🦘"
  fi

  wsuPlayOKSound

else

  fxMessage "🛑 TEST FAILED | phpunit returned ${PHPUNIT_RESULT}"
  wsuPlayKOSound
fi
