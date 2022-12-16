fxHeader "🧙 bin/magento"

expectedUserSetCheck

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi


sudo rm -rf "/tmp/magento"


cd "${MAGENTO_DIR}"
fxInfo "Working in $(pwd)"


if [ ! -f "bin/magento" ]; then
  fxCatastrophicError "##$(realpath bin/magento)## not found!"
fi


if [ -z $(command -v showPHPVer) ]; then
  fxCatastrophicError "PHP not init'd via Webstackup"
fi

showPHPVer


if [ ! -z "$XDEBUG_PORT" ]; then

  export XDEBUG_CONFIG="remote_host=127.0.0.1 client_port=$XDEBUG_PORT"
  export XDEBUG_MODE="develop,debug"
  fxInfo "Xdebug enabled to port ##$XDEBUG_PORT##. Good hunting! 🐛"
  
else

  export XDEBUG_MODE="off"
  fxInfo "Xdebug disabled"
fi


if [ "$EXPECTED_USER" = "$(whoami)" ]; then
  /bin/php${PHP_VER} bin/magento "$@"
else
  sudo -u "$EXPECTED_USER" -H ${PHP_CLI} bin/magento "$@"
fi


fxEndFooter
