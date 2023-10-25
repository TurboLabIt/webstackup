#!/usr/bin/env bash
## Standard WordPress db-dump routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/db-dump.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/db-dump.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

source "${WEBSTACKUP_SCRIPT_DIR}frameworks/db-dump.sh"
