#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/script_begin.sh

APP_NAME="my-app"
PROJECT_FRAMEWORK=my-app-framework
MAGENTO_STATIC_CONTENT_DEPLOY="MyCompany/my-app en_US it_IT fr_FR de_DE en_GB es_ES"

## https://github.com/TurboLabIt/webstackup/blob/master/script/filesystem/script_begin_start.sh
source "/usr/local/turbolab.it/webstackup/script/filesystem/script_begin_start.sh" 

USERS_TEMPLATE_PATH="${PRIVGEN_DIR}operations/accounts/my-company/"

## Enviroment variables and checks
if [ "$APP_ENV" = "prod" ]; then
  EMOJI=robot_face
elif [ "$APP_ENV" = "staging" ]; then
  EMOJI=cat
fi
