#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/run.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript run "$@"
source "${SCRIPT_DIR}script_end.sh"
