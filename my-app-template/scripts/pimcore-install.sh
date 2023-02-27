#!/usr/bin/env bash
## Pimcore installer
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/pimcore-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

PIMCORE_SITE_NAME="My App Name"
SITE_URL=https://my-app.com/
PIMCORE_LOCALE=it_IT
PIMCORE_ADMIN_USERNAME=my-name
PIMCORE_ADMIN_EMAIL=admin@my-app.com
PIMCORE_ADMIN_NEW_SLUG=my-app$(date +"%Y")

source "/etc/turbolab.it/mysql-usr_my-app.conf"

source ${WEBSTACKUP_SCRIPT_DIR}frameworks/pimcore/new.sh

source "${SCRIPT_DIR}/script_end.sh"
