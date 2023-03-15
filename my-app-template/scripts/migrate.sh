#!/usr/bin/env bash
## framework migrations
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/migrate.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript migrate
source "${SCRIPT_DIR}script_end.sh"
