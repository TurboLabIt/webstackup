#!/usr/bin/env bash
## Pimcore installer
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/pimcore-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

source /etc/turbolab.it/mysql-my-app.conf

PIMCORE_SITE_NAME="My App Name"
PIMCORE_LOCALE=it_IT
PIMCORE_ADMIN_USERNAME=my-name
PIMCORE_ADMIN_EMAIL=admin@my-app.com
PIMCORE_ADMIN_NEW_SLUG=my-app$(date +"%Y")

fxCatastrophicError "pimcore-install.sh is not ready!"
source ${WEBSTACKUP_SCRIPT_DIR}frameworks/pimcore/install.sh

source "${SCRIPT_DIR}/script_end.sh"
