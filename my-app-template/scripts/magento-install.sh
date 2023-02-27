#!/usr/bin/env bash
## Pimcore installer
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/magento-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

SITE_URL=https://my-app.com/
MAGENTO_ADMIN_USERNAME=my-name
MAGENTO_ADMIN_EMAIL=admin@my-app.com
MAGENTO_ADMIN_NEW_SLUG=my-app$(date +"%Y")
MAGENTO_LOCALE=it_IT
MAGENTO_CURRENCY=EUR
MAGENTO_TIMEZONE=Europe/Rome

source "/etc/turbolab.it/mysql-usr_my-app.conf"

source ${WEBSTACKUP_SCRIPT_DIR}frameworks/magento/new.sh

source "${SCRIPT_DIR}/script_end.sh"
