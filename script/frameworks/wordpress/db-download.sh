#!/usr/bin/env bash
## Standard WordPress remote-dump and download routine by WEBSTACKUP
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/db-download.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/db-download.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

source "${WEBSTACKUP_SCRIPT_DIR}frameworks/db-download.sh"
