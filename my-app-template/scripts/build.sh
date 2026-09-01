#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/build.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript build "$@"
source "${SCRIPT_DIR}script_end.sh"
