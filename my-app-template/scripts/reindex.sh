#!/usr/bin/env bash
## reindex placeholder
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/reindex.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript reindex
source "${SCRIPT_DIR}script_end.sh"

