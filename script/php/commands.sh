#!/usr/bin/env bash
### READY-TO-RUN, FULLY CUSTOMIZED PHP COMMANDS BY WEBSTACKUP
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
  fxTitle "📦 Running composer..."
  expectedUserSetCheck


  if [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${PROJECT_DIR}composer.json" ]; then

    COMPOSER_JSON_FULLPATH=${PROJECT_DIR}composer.json

  elif [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${WEBROOT_DIR}composer.json" ]; then

    COMPOSER_JSON_FULLPATH=${WEBROOT_DIR}composer.json

  elif [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "composer.json" ]; then

    COMPOSER_JSON_FULLPATH=$(pwd)/composer.json
  fi


  if [ -z "${COMPOSER_JSON_FULLPATH}" ] || [ ! -f "${COMPOSER_JSON_FULLPATH}" ]; then

    fxInfo "composer.json not found"
    fxInfo "$(pwd)"
    local FULL_COMPOSER_CMD="sudo -u $EXPECTED_USER -H XDEBUG_MODE=off COMPOSER_MEMORY_LIMIT=-1 ${PHP_CLI} /usr/local/bin/composer"

  else

    fxInfo "Using ##${COMPOSER_JSON_FULLPATH}##"
    fxInfo "$(dirname ${COMPOSER_JSON_FULLPATH})"
    local FULL_COMPOSER_CMD="sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" XDEBUG_MODE=off COMPOSER_MEMORY_LIMIT=-1 ${PHP_CLI} /usr/local/bin/composer --working-dir="$(dirname ${COMPOSER_JSON_FULLPATH})""
  fi


  if [ ! -z "${APP_ENV}" ] && [ "${APP_ENV}" != "dev" ] && [ "$1" = "install" ]; then
    local NO_DEV="--no-dev"
  fi

  echo "${FULL_COMPOSER_CMD} $@ --no-interaction ${NO_DEV}"
  echo ""

  ${FULL_COMPOSER_CMD} "$@" --no-interaction ${NO_DEV}
}


## Magento bin/console
function wsuMage()
{
  fxTitle "🧙‍♂️ Running Magento..."
  expectedUserSetCheck

  if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
    fxCatastrophicError "📁 MAGENTO_DIR not set"
  fi

  local CONSOLE_FILE_PATH=${MAGENTO_DIR}bin/magento

  if [ ! -f "${CONSOLE_FILE_PATH}" ]; then
    fxCatastrophicError "##${CONSOLE_FILE_PATH}## not found"
  fi

  if [ -d "/tmp/magento" ]; then
    sudo rm -rf "/tmp/magento"
  fi

  local CURR_DIR_BACKUP=$(pwd)

  cd "${MAGENTO_DIR}"

  fxInfo "$(pwd)"
  echo "bin/magento $@"
  echo ""

  sudo -u "${EXPECTED_USER}" -H XDEBUG_MODE=off ${PHP_CLI} ${CONSOLE_FILE_PATH} "$@"

  cd "${CURR_DIR_BACKUP}"
}


## Magento n98-magerun2
function wsuN98MageRun()
{
  expectedUserSetCheck

  if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
    fxCatastrophicError "📁 MAGENTO_DIR not set"
  fi

  sudo rm -rf "/tmp/magento"

  local CURR_DIR_BACKUP=$(pwd)

  cd "${MAGENTO_DIR}"
  sudo -u $EXPECTED_USER -H XDEBUG_MODE=off ${PHP_CLI} /usr/local/bin/n98-magerun2 "$@"

  cd "${CURR_DIR_BACKUP}"
}


## Symfony executable
function wsuSymfony()
{
  if [ "${WSU_SYMFONY_DEBUG_MODE}" = 1 ]; then
    fxTitle "🎼 Running symfony..."
  fi
  
  expectedUserSetCheck

  if [ -z "${PROJECT_DIR}" ] || [ ! -d "${PROJECT_DIR}" ]; then
    fxCatastrophicError "📁 PROJECT_DIR not set"
  fi

  sudo rm -rf "/tmp/symfony"

  local SYMFONY_FILE_PATH=/usr/bin/symfony

  if [ ! -f "${SYMFONY_FILE_PATH}" ]; then
    sudo bash "${WEBSTACKUP_SCRIPT_DIR}frameworks/symfony/install.sh"
  fi

  if [ -z $(command -v unbuffer) ]; then

    fxTitle "unbuffer is not installed. Installing it now..."
    sudo apt update
    sudo apt install expect -y
  fi


  local CURR_DIR_BACKUP=$(pwd)
  cd "${PROJECT_DIR}"


  if [ "${WSU_SYMFONY_DEBUG_MODE}" = 1 ]; then

    fxInfo "Working in $(pwd)"
    echo ""
    showPHPVer
    fxTitle "🐛 Xdebug"
  fi

  
  if [ "$APP_ENV" = dev ] && [ ! -z "$XDEBUG_PORT" ]; then

    export XDEBUG_CONFIG="remote_host=127.0.0.1 client_port=$XDEBUG_PORT"
    export XDEBUG_MODE="develop,debug"

    if [ "${WSU_SYMFONY_DEBUG_MODE}" = 1 ]; then

      fxOK "Xdebug enabled to port ##$XDEBUG_PORT##. Good hunting!"
      fxInfo "To disable: export XDEBUG_PORT="
    fi

  else

    export XDEBUG_MODE="off"
    if [ "${WSU_SYMFONY_DEBUG_MODE}" = 1 ]; then
      fxInfo "Xdebug disabled (to enable: export XDEBUG_PORT=9999)"
    fi
  fi


  if [ "$EXPECTED_USER" = "$(whoami)" ]; then
    symfony "$@"
  else
    sudo -u "$EXPECTED_USER" -H symfony "$@"
  fi
}


## WordPress CLI
function wsuWordPress()
{
  fxTitle "📰 Running wp-cli..."
  expectedUserSetCheck

  if [ -z "${WEBROOT_DIR}" ] || [ ! -d "${WEBROOT_DIR}" ]; then
    fxCatastrophicError "📁 WEBROOT_DIR not set"
  fi

  local WPCLI_FILE_PATH=/usr/local/bin/wp-cli

  if [ ! -f "${WPCLI_FILE_PATH}" ]; then
    sudo bash "${WEBSTACKUP_SCRIPT_DIR}frameworks/wordpress/install.sh"
  fi

  local CURR_DIR_BACKUP=$(pwd)

  cd "${WEBROOT_DIR}"

  fxInfo "$(pwd)"
  echo "wp-cli $@"
  echo ""

  sudo -u $EXPECTED_USER -H XDEBUG_MODE=off ${PHP_CLI} ${WPCLI_FILE_PATH} --path="${WEBROOT_DIR%*/}/" --allow-root $@

  cd "${CURR_DIR_BACKUP}"
}


function wsuOpcacheClear()
{
  sudo service ${PHP_FPM} reload
  return 0

  ## cachetool https://github.com/gordalina/cachetool
  # The application requires the version ">=8.0.0" or greater
  local CACHETOOL_FILE_PATH=/usr/local/bin/cachetool

  if [ ! -f "${CACHETOOL_FILE_PATH}" ]; then
    fxTitle "cachetool is not installed. Installing..."
    sudo curl -Lo "${CACHETOOL_FILE_PATH}" https://github.com/gordalina/cachetool/releases/latest/download/cachetool.phar
    sudo chmod u=rwx,go=rx "${CACHETOOL_FILE_PATH}"
  fi

  local CACHETOOL_EXE="${PHP_CLI} ${CACHETOOL_FILE_PATH}"
  sudo ${CACHETOOL_EXE} opcache:reset --fcgi=/run/php/${PHP_FPM}.sock
}
