#!/usr/bin/env bash
## Pimcore installer
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/pimcore-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

PIMCORE_SITE_NAME="My App Name"
PIMCORE_LOCALE=it_IT
PIMCORE_ADMIN_USERNAME=my-name
PIMCORE_ADMIN_EMAIL=admin@my-app.com
PIMCORE_ADMIN_NEW_SLUG=my-app$(date +"%Y")

MYSQL_USER=my-app
## ☠️☠️ DON'T GIT COMMIT THE PASSWORD ☠️☠️ ##
MYSQL_PASSWORD=
MYSQL_HOST=localhost
SITE_URL=https://my-app.com

source ${WEBSTACKUP_SCRIPT_DIR}frameworks/pimcore/install.sh

source "${SCRIPT_DIR}/script_end.sh"
