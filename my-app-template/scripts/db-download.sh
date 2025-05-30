#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/db-download.sh

source $(dirname $(readlink -f $0))/script_begin.sh

## download from...
if [ "${1}" == "staging" ]; then

  REMOTE_SERVER=next.my-app.com
  REMOTE_APP_ENV=staging

else

  REMOTE_SERVER=my-app.com
  REMOTE_APP_ENV=prod
fi

REMOTE_SSH_USERNAME=
REMOTE_PROJECT_DIR=/var/www/my-app/
DISABLE_SSH_TEST=0


wsuSourceFrameworkScript db-download

source "${SCRIPT_DIR}script_end.sh"
