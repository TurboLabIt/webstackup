#!/usr/bin/env bash
echo ""
SCRIPT_NAME=auto-update

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "✳ ${SCRIPT_NAME}"
rootCheck

AUTOUPD_PROJECT_DIR=$1
if [ -z "$AUTOUPD_PROJECT_DIR" ]; then
  fxCatastrophicError "auto-update.sh requires the PROJECT_DIR as first argument"
fi


fxGitCheckForUpdate
AUTOUPD_NEED_UPDATE=$?

if [ "${AUTOUPD_NEED_UPDATE}" == "1" ] && [ -f "${AUTOUPD_PROJECT_DIR}scripts/deploy.sh" ]; then

  ## setsid: no controlling terminal, so the PROD confirmation proceeds unattended even when run by hand (as it does from cron)
  echo "1" | setsid -w bash "${AUTOUPD_PROJECT_DIR}scripts/deploy.sh"

elif [ "${AUTOUPD_NEED_UPDATE}" == "1" ]; then

  fxGit "${AUTOUPD_PROJECT_DIR}" pull
fi

fxEndFooter
