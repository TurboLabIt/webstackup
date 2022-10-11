### AUTOMATIC WORDPRESS SETUP BY WEBSTACK.UP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/wordpress-install.sh

### Variables:
# WEBROOT_DIR=
# EXPECTED_USER=

# MYSQL_DB_NAME=
# MYSQL_USER=
# MYSQL_HOST=
# MYSQL_PASSWORD=
# 
# SITE_URL=
# WORDPRESS_SITE_NAME="🚀 WordPress"
# WORDPRESS_LOCALE=it_IT

# WORDPRESS_ADMIN_USERNAME=
# WORDPRESS_ADMIN_EMAIL=

# WORDPRESS_MULTISITE_MODE=<null> | subfolders | subdomains
# WORDPRESS_ADMIN_NEW_SLUG=

rootCheck

if [ -z "${APP_NAME}" ] || [ -z "${WEBROOT_DIR}" ] || [ -z "${WORDPRESS_LOCALE}" ] || \
   [ -z "${MYSQL_DB_NAME}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_PASSWORD}" ] || \
   [ -z "${SITE_URL}" ] ||  [ -z "${WORDPRESS_SITE_NAME}" ] || \
   [ -z "${WORDPRESS_ADMIN_USERNAME}" ] || [ -z "${WORDPRESS_ADMIN_EMAIL}" ] || [ -z "${WORDPRESS_ADMIN_NEW_SLUG}" ] \
   ; then

  catastrophicError "WordPress installer can't run with these variables undefined:

  APP_NAME:                  ##${APP_NAME}##
  WEBROOT_DIR:               ##${WEBROOT_DIR}##
  WORDPRESS_LOCALE:          ##${WORDPRESS_LOCALE}##
  MYSQL_DB_NAME:             ##${MYSQL_DB_NAME}##
  MYSQL_USER:                ##${MYSQL_USER}##
  MYSQL_HOST:                ##${MYSQL_HOST}##
  MYSQL_PASSWORD:            ##${MYSQL_PASSWORD}##
  SITE_URL:                  ##${SITE_URL}##
  WORDPRESS_SITE_NAME:       ##${WORDPRESS_SITE_NAME}##
  WORDPRESS_ADMIN_USERNAME:  ##${WORDPRESS_ADMIN_USERNAME}##
  WORDPRESS_ADMIN_EMAIL:     ##${WORDPRESS_ADMIN_EMAIL}##
  WORDPRESS_ADMIN_NEW_SLUG:  ##${WORDPRESS_ADMIN_NEW_SLUG}##"
  exit
fi


WPINST_WEBROOT_DIR=${WEBROOT_DIR%*/}/
WPINST_FIRST_ADMIN_PASSWORD=$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)
WPINST_SITE_DOMAIN=$(echo $SITE_URL | sed 's/https\?:\/\///')
WPINST_SITE_DOMAIN=${WPINST_SITE_DOMAIN%*/}


if [ ! -f /usr/local/bin/wp-cli ]; then
  fxTitle "💿 Installing wp-cli..."
  curl -o /usr/local/bin/wp-cli  https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod u=rwx,go=rx /usr/local/bin/wp-cli
fi


fxTitle "Downloading WordPress..."
# https://developer.wordpress.org/cli/commands/core/download/
wsuWordPress core download --locale="${WORDPRESS_LOCALE}"


fxTitle "Checking WordPress version..."
wsuWordPress core version


fxTitle "Creating wp-config.php..."
## https://developer.wordpress.org/cli/commands/config/create/
wsuWordPress config create \
  --dbname="${MYSQL_DB_NAME}" \
  --dbuser="${MYSQL_USER}" \
  --dbhost="${MYSQL_HOST}" \
  --dbpass="${MYSQL_PASSWORD}" \
  --locale="${WORDPRESS_LOCALE}"


fxTitle "Adding extra configs to wp-config.php"
echo "/** Webstackup -- Fix install plugins/themes via admin */" >> "${WPINST_WEBROOT_DIR}wp-config.php"
echo "define('FS_METHOD', 'direct');" >> "${WPINST_WEBROOT_DIR}wp-config.php"
echo "/** Webstackup -- Auto-update: security and minor only */" >> "${WPINST_WEBROOT_DIR}wp-config.php"
echo "define('WP_AUTO_UPDATE_CORE', 'minor');" >> "${WPINST_WEBROOT_DIR}wp-config.php"


if [ ! -z "$WORDPRESS_MULTISITE_MODE" ]; then

  # https://developer.wordpress.org/cli/commands/core/multisite-install/
  WPINST_WORDPRESS_INSTALL_MODE=multisite-install
  
else

  # https://developer.wordpress.org/cli/commands/core/install/
  WPINST_WORDPRESS_INSTALL_MODE=install
fi

if [ "$WORDPRESS_MULTISITE_MODE" = "subdomains" ] || [ "$WORDPRESS_MULTISITE_MODE" = "subdomain" ]; then

  # https://developer.wordpress.org/cli/commands/core/multisite-install/
  WPINST_WORDPRESS_MULTISITE_MODE_ARGUMENT=--subdomains
fi


wsuWordPress core $WPINST_WORDPRESS_INSTALL_MODE $WPINST_WORDPRESS_MULTISITE_MODE_ARGUMENT \
  --url="${WPINST_SITE_DOMAIN}" \
  --title="${WORDPRESS_SITE_NAME}" \
  --admin_user="${WORDPRESS_ADMIN_USERNAME}" \
  --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
  --admin_password="${WPINST_FIRST_ADMIN_PASSWORD}" \
  --skip-email


fxTitle "Installing WordPress plugin..."
## https://developer.wordpress.org/cli/commands/plugin/install/
# https://wordpress.org/plugins/wps-hide-login/
# https://wordpress.org/plugins/duracelltomi-google-tag-manager/
# https://wordpress.org/plugins/seo-by-rank-math/
# https://wordpress.org/plugins/webp-express/
# https://wordpress.org/plugins/timber-library/
# https://wordpress.org/plugins/advanced-custom-fields/
# https://wordpress.org/plugins/google-authenticator/
# https://wordpress.org/plugins/autoptimize/
# https://wordpress.org/plugins/classic-editor/
# https://wordpress.org/plugins/radio-buttons-for-taxonomies/
# https://wordpress.org/plugins/regenerate-thumbnails/
# https://wordpress.org/plugins/wp-fastest-cache/

wsuWordPress plugin install \
  wps-hide-login duracelltomi-google-tag-manager seo-by-rank-math \
  webp-express timber-library advanced-custom-fields \
  google-authenticator autoptimize classic-editor \
  radio-buttons-for-taxonomies regenerate-thumbnails wp-fastest-cache \
  --activate-network --activate
  
fxTitle "Enable plugin auto-update..."
## https://developer.wordpress.org/cli/commands/plugin/auto-updates/
wsuWordPress plugin auto-updates enable --all

fxTitle "Setting some options..."
## https://wordpress.org/support/topic/change-admin-url-through-wp-cli/
wsuWordPress option update \
  whl_page "${WORDPRESS_ADMIN_NEW_SLUG}" \
  --skip-plugins --skip-themes
 
fxTitle "Preparing ${APP_NAME} theme directory..."
mkdir -p "${WPINST_WEBROOT_DIR}wp-content/themes/${APP_NAME}"
echo "Put your own theme here. It will be Git-commitable" > "${WPINST_WEBROOT_DIR}wp-content/themes/${APP_NAME}/readme.md"

fxTitle "Preparing ${APP_NAME} plugin directory..."
mkdir -p "${WPINST_WEBROOT_DIR}wp-content/plugins/${APP_NAME}"
echo "Put your own plugin here. It will be Git-commitable" > "${WPINST_WEBROOT_DIR}wp-content/plugins/${APP_NAME}/readme.md"

fxTitle "Downloading .gitignore"
curl -o "${WPINST_WEBROOT_DIR}.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore_wordpress?$(date +%s)
sed -i "s|my-app|${APP_NAME}|g" "${WPINST_WEBROOT_DIR}.gitignore"

fxTitle "Set the permissions"
chown webstackup:www-data ${WPINST_WEBROOT_DIR} -R
chmod u=rwx,g=rwX,o=rX ${WPINST_WEBROOT_DIR} -R
chmod u=rw,g=r,o= ${WPINST_WEBROOT_DIR}wp-config.php

fxMessage "Your admin password is: $WPINST_FIRST_ADMIN_PASSWORD"
