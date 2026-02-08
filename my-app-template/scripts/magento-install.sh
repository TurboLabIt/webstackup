#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/magento-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

SITE_URL=https://my-app.com/
MAGENTO_MARKET_PUBKEY=9f7e8b6fe7fe586fe1541551d07c28e6
MAGENTO_MARKET_PRIVKEY=dd1549a69f7681cc21e26bb461efd387
ELASTICSEARCH_HOST=localhost
MAGENTO_ADMIN_USERNAME="$(logname)"
MAGENTO_ADMIN_EMAIL=admin@my-app.com
MAGENTO_ADMIN_NEW_SLUG=my-app$(date +"%Y")
MAGENTO_LOCALE=it_IT
MAGENTO_CURRENCY=EUR
MAGENTO_TIMEZONE=Europe/Rome
## it's recommended to leave MAGENTO_VERSION= commented or empty to get the latest version.
## But, if you need a specific Magento version, set it here 👇🏻
#MAGENTO_VERSION=x.y.z

source "/etc/turbolab.it/mysql-${APP_NAME}.conf"

source ${WEBSTACKUP_SCRIPT_DIR}frameworks/magento/new.sh

source "${SCRIPT_DIR}/script_end.sh"
