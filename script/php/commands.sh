#!/usr/bin/env bash
### READY-TO-RUN, FULLY CUSTOMIZED PHP COMMANDS BY WEBSTACK.UP
#
# wsuMage cache:flush
# wsuComposer install
#
# COMPOSER_JSON_FULLPATH
# COMPOSER_SKIP_DUMP_AUTOLOAD

source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/version-variables.sh


## composer
function wsuComposer()
{
  fxTitle "📦 Running Composer..."
  expectedUserSetCheck
  
  if [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${PROJECT_DIR}composer.json" ]; then

    COMPOSER_JSON_FULLPATH=${PROJECT_DIR}composer.json

  elif [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${WEBROOT_DIR}composer.json" ]; then

    COMPOSER_JSON_FULLPATH=${WEBROOT_DIR}composer.json
  fi
  
  if [ ! -z "${APP_ENV}" ] && [ "${APP_ENV}" != "dev" ] && [ "$1" = "install" ]; then
    local NO_DEV="--no-dev"
  fi
  
  local FULL_COMPOSER_CMD="sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" ${PHP_CLI} /usr/local/bin/composer --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})" --no-interaction ${NO_DEV}"

  if [ ! -z "${COMPOSER_JSON_FULLPATH}" ]; then
  
    fxMessage "Using ##${COMPOSER_JSON_FULLPATH}##"
    rm -f "$(dirname ${COMPOSER_JSON_FULLPATH})/vendor/composer/autoload_classmap.php"
    ${FULL_COMPOSER_CMD} $@  
  
  fi
  
  local SYMFONY_FLEX="$(dirname ${COMPOSER_JSON_FULLPATH})/vendor/flex/src/Command/DumpEnvCommand.php"
  
  if [ ! -z "${COMPOSER_JSON_FULLPATH}" ] && [ ! -z "${APP_ENV}" ] && [ -f "${SYMFONY_FLEX_DUMP_ENV_COMMAND}" ]; then
    fxTitle "📦 dump-env ${APP_ENV}..."
    ${FULL_COMPOSER_CMD} dump-env ${APP_ENV}
  fi
}


## Magento bin/console
function wsuMage()
{
  fxTitle "🧙 Running Magento bin/console..."
  expectedUserSetCheck
  
  if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
    fxCatastrophicError "📁 MAGENTO_DIR not set"
  fi
  
  sudo rm -rf "/tmp/magento"
  
  local CURR_DIR_BACKUP=$(pwd)

  cd "${MAGENTO_DIR}"
  sudo -u "${EXPECTED_USER}" -H ${PHP_CLI} bin/magento $@
  
  cd "${CURR_DIR_BACKUP}"
}
