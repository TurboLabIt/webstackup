#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/auto-update.sh

source $(dirname $(readlink -f $0))/script_begin.sh
bash "${WEBSTACKUP_SCRIPT_DIR}filesystem/auto-update.sh" "${PROJECT_DIR}"
source "${SCRIPT_DIR}script_end.sh"
