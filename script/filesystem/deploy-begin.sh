fxHeader "🤖 ${APP_NAME} deploy script"
fxTitle "Running on ${APP_ENV} ($HOSTNAME)"
rootCheck


if [ -z "${PROJECT_DIR}" ] || [ -z "${APP_ENV}" ] || [ -z "${APP_NAME}" ]; then

  catastrophicError "Deploy can't run with these variables undefined:
  PROJECT_DIR:    ##${PROJECT_DIR}##
  APP_ENV:        ##${APP_ENV}##
  APP_NAME:       ##${APP_NAME}##"
  exit
fi


if [ ! -d "$PROJECT_DIR" ]; then
  fxCatastrophicError "PROJECT_DIR ##${PROJECT_DIR}## doesn't exist!"
fi


if [ "$1" = "fast" ]; then
  fxTitle "🐇 Fast mode"
  IS_FAST=1
else
  printTitle "🐢 Slow mode (non-fast)"
  IS_FAST=0
fi

if [ "$APP_ENV" = "prod" ]; then

  fxTitle '⚡⚡ You are about to deploy ${APP_NAME} on PRODUCTION ($HOSTNAME) ⚡⚡'
  local options=("OK" "Cancel")
  select opt in "${options[@]}"
  do
    case $opt in

      "OK")
        break
        ;;

      "Cancel")
        if [ -f "${SCRIPT_DIR}script_end.sh" ]; then
          source ${SCRIPT_DIR}script_end.sh
        fi
        exit
        ;;

      *) echo "👎🏻 Invalid option";;
    esac
  done

fi

if [ -z "${LOCKFILE}" ]; then
  LOCKFILE=/tmp/deploy-${APP_ENV}
fi

lockCheck "${LOCKFILE}"

if [ -f "${SCRIPT_DIR}notify.sh" ]; then
  bash "${SCRIPT_DIR}notify.sh" "deploy-start" "$1"
fi

fxTitle "Disable xdebug..."
export XDEBUG_MODE=off

fxTitle "Switch to project directory"
cd ${PROJECT_DIR}
pwd
