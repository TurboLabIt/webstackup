#!/usr/bin/env bash
## Framework-based database remote-dump and download by WEBSTACKUP
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/db-download.sh

source $(dirname $(readlink -f $0))/script_begin.sh
wsuSourceFrameworkScript db-download
