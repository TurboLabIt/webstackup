#!/usr/bin/env bash
## WordPress installer
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/wordpress-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

source /etc/turbolab.it/mysql-my-app.conf

WORDPRESS_SITE_NAME="My App Name"
WORDPRESS_LOCALE=it_IT
WORDPRESS_ADMIN_USERNAME=my-name
WORDPRESS_ADMIN_EMAIL=admin@my-app.com
WORDPRESS_MULTISITE_MODE=
WORDPRESS_ADMIN_NEW_SLUG=my-app$(date +"%Y")

fxCatastrophicError "wordpress-install.sh is not ready!"
source ${WEBSTACKUP_SCRIPT_DIR}frameworks/wordpress/install.sh

source "${SCRIPT_DIR}/script_end.sh"

