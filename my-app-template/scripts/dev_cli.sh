#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/dev_cli.sh

SCRIPT_NAME=dev_cli
source $(dirname $(readlink -f $0))/script_begin.sh
fxHeader "🧑‍💻 DEV cli"
fxTitle "Running on ${APP_ENV} ($HOSTNAME)"
devOnlyCheck

#fxTitle "Changing permissions..."
#sudo chmod ugo=rwx "${PROJECT_DIR}" -R

if [ "$1" = "cache" ]; then

  bash "${SCRIPT_DIR}cache-clear.sh" $2

elif [ "$1" = "composer" ]; then

  wsuComposer "${@:2}"

elif [ "$1" = "db:refresh" ]; then

  bash "${SCRIPT_DIR}db-download.sh"
  bash "${SCRIPT_DIR}db-load.sh"

elif [ "$1" = "example" ]; then

  clear
  bash "${SCRIPT_DIR}cli.sh" orders:export "${@:2}"

else

  fxCatastrophicError "Please provide a defined procedure"
fi

#fxTitle "Changing permissions..."
#sudo chmod ugo=rwx "${PROJECT_DIR}" -R

source ${SCRIPT_DIR}script_end.sh

