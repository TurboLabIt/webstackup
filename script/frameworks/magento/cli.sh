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


## Adobe's Commerce Version Tool, shipped by the isolated security patches (see cache-clear.sh)
# scripts/cli.sh patch
if [ "$1" = "patch" ]; then

  MAGENTO_PATCH_STATUS_EXE="${MAGENTO_DIR}vendor/bin/patch-status"
  if [ ! -f "${MAGENTO_PATCH_STATUS_EXE}" ]; then
    fxCatastrophicError "##${MAGENTO_PATCH_STATUS_EXE}## not found!"
  fi

  if [ -z "$(command -v jq)" ]; then
    fxAptUpdate && sudo apt install jq -y
  fi

  fxTitle "🩹 Magento patch status..."
  ## --no-cache: always check against Adobe's current list. The cached copy is reused for up to 1 hour, and at any
  ## age when repo.magento.com doesn't answer (still exiting 0): with --no-cache that's an exit 1, so it ends red below
  MAGENTO_PATCH_STATUS_JSON=$(sudo -u "${EXPECTED_USER}" -H XDEBUG_MODE=off ${PHP_CLI} "${MAGENTO_PATCH_STATUS_EXE}" --no-cache)

  ## on failure (e.g. unknown base version) it can still print a JSON with empty lists: "None" would be a lie.
  ## The output format "is not final and may change" (patch-status --help): a renamed node would read as "None" too
  if [ "$?" != 0 ] || ! jq -e 'has("missing_patches") and has("vulnerability_status")' <<< "${MAGENTO_PATCH_STATUS_JSON}" > /dev/null 2>&1; then
    echo "${MAGENTO_PATCH_STATUS_JSON}"
    fxCatastrophicError "patch-status failed"
  fi

  ## jq -e exits non-zero when select() leaves nothing to print
  fxTitle "Missing patches"
  jq -e '.missing_patches | select(length > 0)' <<< "${MAGENTO_PATCH_STATUS_JSON}" || fxOK "None"

  fxTitle "Vulnerabilities"
  jq -e '.vulnerability_status | with_entries(select(.value.status != "PROTECTED" and .value.status != "NOT_APPLICABLE")) | select(length > 0)' <<< "${MAGENTO_PATCH_STATUS_JSON}" || fxOK "None"

  fxTitle "Full report"
  jq . <<< "${MAGENTO_PATCH_STATUS_JSON}"

  return 0
fi


fxTitle "🐛 Xdebug"
if [ "$APP_ENV" = dev ] && [ ! -z "$XDEBUG_PORT" ]; then

  export XDEBUG_CONFIG="client_port=$XDEBUG_PORT"
  export XDEBUG_MODE="develop,debug"
  export XDEBUG_TRIGGER=1
  fxOK "Xdebug enabled to port ##$XDEBUG_PORT##. Good hunting!"
  fxInfo "To disable: export XDEBUG_PORT="
  
else

  export XDEBUG_MODE="off"
  fxInfo "Xdebug disabled (to enable: export XDEBUG_PORT=9999)"
fi


fxTitle "🌋 bin/magento"
if [ "$EXPECTED_USER" = "$(whoami)" ]; then
  /bin/php${PHP_VER} bin/magento "$@"
else
  sudo -u "$EXPECTED_USER" -H ${PHP_CLI} bin/magento "$@"
fi
