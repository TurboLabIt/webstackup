#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/wordpress-generate-jwt-token.sh

source $(dirname $(readlink -f $0))/script_begin.sh

fxHeader "👛 Generate JWT token on WordPress"

#SITE_URL=${WORDPRESS_URL}
#SITE_HTTP_BASIC_AUTH_USER_PASSWORD="myUser:myPass"

echo "📚 https://bitbucket.org/my-name/my-app/wiki/WordPress%20integration%20guide"
echo "💡 The required password is on https://www.lastpass.com"

## https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/wordpress/generate-jwt-token.sh
source ${WEBSTACKUP_SCRIPT_DIR}frameworks/wordpress/generate-jwt-token.sh

source "${SCRIPT_DIR}/script_end.sh"
