#!/usr/bin/env bash
## Framework-based database remote-dump and download by WEBSTACKUP
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/db-download.sh

source $(dirname $(readlink -f $0))/script_begin.sh

REMOTE_SERVER=my-app.com
REMOTE_SSH_USERNAME=
REMOTE_PROJECT_DIR=/var/www/my-app/
REMOTE_APP_ENV=prod
DISABLE_SSH_TEST=0

wsuSourceFrameworkScript db-download

source "${SCRIPT_DIR}script_end.sh"
