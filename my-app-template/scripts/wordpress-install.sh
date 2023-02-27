#!/usr/bin/env bash
## WordPress installer
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/wordpress-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

WORDPRESS_SITE_NAME="My App Name"
SITE_URL=https://my-app.com
WORDPRESS_LOCALE=it_IT
WORDPRESS_ADMIN_USERNAME=my-name
WORDPRESS_ADMIN_EMAIL=admin@my-app.com
WORDPRESS_MULTISITE_MODE=
WORDPRESS_ADMIN_NEW_SLUG=my-app$(date +"%Y")

source "/etc/turbolab.it/mysql-usr_my-app.conf"

source ${WEBSTACKUP_SCRIPT_DIR}frameworks/wordpress/new.sh

source "${SCRIPT_DIR}/script_end.sh"
