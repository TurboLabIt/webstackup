#!/usr/bin/env bash
## This is the main cron job for your framework. It runs here: 
#    https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/cron
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/cron.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript cron "$@"
source "${SCRIPT_DIR}script_end.sh"
