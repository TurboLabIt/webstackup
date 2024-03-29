#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/pimcore-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

SITE_URL=https://my-app.com/
PIMCORE_ADMIN_USERNAME="$(logname)"
PIMCORE_ADMIN_NEW_SLUG=my-app$(date +"%Y")
PIMCORE_LOCALE=it_IT

source "/etc/turbolab.it/mysql-${APP_NAME}.conf"

source ${WEBSTACKUP_SCRIPT_DIR}frameworks/pimcore/new.sh

source "${SCRIPT_DIR}/script_end.sh"
