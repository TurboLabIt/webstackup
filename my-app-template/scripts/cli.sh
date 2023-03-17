#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/cli.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript cli "$@"
source "${SCRIPT_DIR}script_end.sh"
