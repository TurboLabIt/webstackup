#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/script_begin.sh

APP_NAME="my-app"
USERS_TEMPLATE_PATH="${PRIVGEN_DIR}operations/accounts/my-company/"
PROJECT_FRAMEWORK=my-app-framework
MAGENTO_STATIC_CONTENT_DEPLOY="MyCompany/my-app en_US it_IT fr_FR de_DE en_GB es_ES"

## https://github.com/TurboLabIt/webstackup/blob/master/script/filesystem/script_begin_start.sh
source "/usr/local/turbolab.it/webstackup/script/filesystem/script_begin_start.sh" 
