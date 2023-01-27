#!/usr/bin/env bash
## Standard Symfony db-dump routine by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/db-dump.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/db-dump.sh && sudo chmod u=rwx,go=rx scripts/db-dump.sh
#
# 1. You should now git commit your copy

zzmysqldump "${APP_NAME}"
