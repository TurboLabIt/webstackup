#!/usr/bin/env bash
## Run the project tests and check the result
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/test-runner.sh

TESTR_SCRIPT_BEGIN=$(dirname $(readlink -f $0))/script_begin.sh
if [ -f "${TESTR_SCRIPT_BEGIN}" ]; then
  source "${TESTR_SCRIPT_BEGIN}"
else
  source "/usr/local/turbolab.it/webstackup/script/base.sh"
  APP_NAME=my-app
  EXPECTED_USER=$(logname)
fi

fxHeader "🧪 ${APP_NAME} Test Runner"

# https://github.com/TurboLabIt/webstackup/tree/master/script/php/test-runner-package.sh
source "${WEBSTACKUP_SCRIPT_DIR}php/test-runner-package.sh"

fxTitle "🧹 Cleaning up..."
#rm -rf /tmp/any-temp-dir

TESTR_SCRIPT_END=$(dirname $(readlink -f $0))/script_end.sh
if [ -f "${TESTR_SCRIPT_END}" ]; then
  source "${TESTR_SCRIPT_END}"
else
  fxEndFooter
fi
