#!/usr/bin/env bash
## Framework-based database dump loader by WEBSTACKUP
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/db-load.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript db-load
