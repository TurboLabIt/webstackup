#!/usr/bin/env bash
## Framework-based clear-cache by WEBSTACKUP
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/maintenance.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript maintenance "$1"
