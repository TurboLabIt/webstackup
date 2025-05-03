#!/usr/bin/env bash
## Complete deploy script for every project. Hookable via "moments".
#
# ⚠️ Don't run this script directly! Run https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/deploy_run.sh instead!

fxHeader "🤖 ${APP_NAME} deploy script"
fxTitle "Running on ${APP_ENV} ($HOSTNAME)"
rootCheck

if [ -f "${SCRIPT_DIR}deploy_moment_010.sh" ]; then
  source "${SCRIPT_DIR}deploy_moment_010.sh"
fi

if [ -z "${PROJECT_DIR}" ] || [ -z "${APP_ENV}" ] || [ -z "${APP_NAME}" ]; then

  fxCatastrophicError "Deploy can't run with these variables undefined:
  PROJECT_DIR:    ##${PROJECT_DIR}##
  APP_ENV:        ##${APP_ENV}##
  APP_NAME:       ##${APP_NAME}##"
fi

if [ ! -d "$PROJECT_DIR" ]; then
  fxCatastrophicError "PROJECT_DIR ##${PROJECT_DIR}## doesn't exist!"
fi


fxTitle "Fast mode check..."
if [ "$1" = "fast" ]; then

  fxOK "🐇 Fast mode"
  IS_FAST=1

else

  fxOK "🐢 Slow mode (non-fast)"
  IS_FAST=0
fi


fxTitle "Env check..."
fxOK "$APP_ENV"
if [ "$APP_ENV" == "prod" ]; then
  fxAskConfirmation "You are about to deploy ${APP_NAME} on PRODUCTION ($HOSTNAME)"
fi


if [ -z "${LOCKFILE}" ]; then
  LOCKFILE=/tmp/deploy-${APP_NAME}
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

if [ -f "${SCRIPT_DIR}deploy_moment_030.sh" ]; then
  source "${SCRIPT_DIR}deploy_moment_030.sh"
fi

WSU_FRAMEWORK_PREDEPLOY=${WEBSTACKUP_SCRIPT_DIR}frameworks/${PROJECT_FRAMEWORK}/pre-deploy.sh
if [ -f "${WSU_FRAMEWORK_PREDEPLOY}" ]; then
  source "${WSU_FRAMEWORK_PREDEPLOY}"
fi

if [ -f "${SCRIPT_DIR}db-dump.sh" ]; then
  bash "${SCRIPT_DIR}db-dump.sh"
fi

if [ -f "${SCRIPT_DIR}deploy_moment_050.sh" ]; then
  source "${SCRIPT_DIR}deploy_moment_050.sh"
fi

source "${WEBSTACKUP_SCRIPT_DIR}filesystem/deploy-common.sh"

if [ -f "${SCRIPT_DIR}deploy_moment_070.sh" ]; then
  source "${SCRIPT_DIR}deploy_moment_070.sh"
fi

if [ -f "${SCRIPT_DIR}notify.sh" ]; then
  bash ${SCRIPT_DIR}notify.sh "deploy-end" "$1"
fi
