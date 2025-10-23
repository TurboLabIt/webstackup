#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/crawl.sh

source $(dirname $(readlink -f $0))/script_begin.sh
## https://github.com/TurboLabIt/webstackup/blob/master/script/https/crawl.sh
source ${WEBSTACKUP_SCRIPT_DIR}https/crawl.sh
source "${SCRIPT_DIR}script_end.sh"
