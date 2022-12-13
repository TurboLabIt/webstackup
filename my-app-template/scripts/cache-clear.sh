#!/usr/bin/env bash
## Framework-based clear-cache by WEBSTACKUP
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/clear-cache.sh

source $(dirname $(readlink -f $0))/script_begin.sh
WSU_MAP_FRAMEWORK_CACHECLEAR="${WEBSTACKUP_SCRIPT_DIR}frameworks/${PROJECT_FRAMEWORK}/cache-clear.sh"
if [ -f "${WSU_MAP_FRAMEWORK_CACHECLEAR}" ]; then
  source "${WEBSTACKUP_SCRIPT_DIR}frameworks/${PROJECT_FRAMEWORK}/cache-clear.sh"
  source "${SCRIPT_DIR}/script_end.sh"
else
  fxInfo "No clear-cache script available for your ##${PROJECT_FRAMEWORK}## framework"
fi
