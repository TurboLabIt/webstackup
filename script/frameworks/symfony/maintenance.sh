#!/usr/bin/env bash
## Standard Symfony maintenance by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/maintenance.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/maintenance.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

source "${WEBSTACKUP_SCRIPT_DIR}nginx/maintenance.sh"
