#!/usr/bin/env bash
## Standard Pimcore database dump loader routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/db-load.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/db-load.sh && sudo chmod u=rwx,go=rx scripts/db-load.sh
#
# 1. You should now git commit your copy

source "${WEBSTACKUP_SCRIPT_DIR}frameworks/db-load.sh"
