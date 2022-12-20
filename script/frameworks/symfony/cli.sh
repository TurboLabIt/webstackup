fxHeader "🎶 symfony bin/console"

expectedUserSetCheck

if [ -z "${PROJECT_DIR}" ] || [ ! -d "${PROJECT_DIR}" ]; then
  fxCatastrophicError "📁 PROJECT_DIR not set"
fi


sudo rm -rf "/tmp/symfony"


cd "${PROJECT_DIR}"
fxInfo "Working in $(pwd)"


if [ ! -f "bin/console" ]; then
  fxCatastrophicError "##$(realpath bin/console)## not found!"
fi


if [ -z $(command -v showPHPVer) ]; then
  fxCatastrophicError "PHP not init'd via Webstackup"
fi

showPHPVer


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


fxTitle "🌋 symfony console"
if [ "$EXPECTED_USER" = "$(whoami)" ]; then
  /bin/php${PHP_VER} /usr/local/bin/symfony console "$@"
else
  sudo -u "$EXPECTED_USER" -H ${PHP_CLI} /usr/local/bin/symfony console "$@"
fi
