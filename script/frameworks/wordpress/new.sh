### AUTOMATIC WORDPRESS SETUP BY WEBSTACKUP
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

fxHeader "🆕 WordPress create new instance"
rootCheck


if [ ! -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
fi  


if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ] || [ -z "${WORDPRESS_LOCALE}" ] || \
   [ -z "${MYSQL_DB_NAME}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_PASSWORD}" ] || \
   [ -z "${SITE_URL}" ] ||  [ -z "${WORDPRESS_SITE_NAME}" ] || \
   [ -z "${WORDPRESS_ADMIN_USERNAME}" ] || [ -z "${WORDPRESS_ADMIN_EMAIL}" ] || [ -z "${WORDPRESS_ADMIN_NEW_SLUG}" ] \
   ; then

  catastrophicError "WordPress installer can't run with these variables undefined:

  APP_NAME:                  ##${APP_NAME}##
  PROJECT_DIR:               ##${PROJECT_DIR}##
  WORDPRESS_LOCALE:          ##${WORDPRESS_LOCALE}##
  MYSQL_DB_NAME:             ##${MYSQL_DB_NAME}##
  MYSQL_USER:                ##${MYSQL_USER}##
  MYSQL_HOST:                ##${MYSQL_HOST}##
  MYSQL_PASSWORD:            ##${MYSQL_PASSWORD_HIDDEN}##
  SITE_URL:                  ##${SITE_URL}##
  WORDPRESS_SITE_NAME:       ##${WORDPRESS_SITE_NAME}##
  WORDPRESS_ADMIN_USERNAME:  ##${WORDPRESS_ADMIN_USERNAME}##
  WORDPRESS_ADMIN_EMAIL:     ##${WORDPRESS_ADMIN_EMAIL}##
  WORDPRESS_ADMIN_NEW_SLUG:  ##${WORDPRESS_ADMIN_NEW_SLUG}##"
  exit
fi

PROJECT_DIR_BACKUP=${PROJECT_DIR}
WEBROOT_DIR_BACKUP=${WEBROOT_DIR}
CURRENT_DIR_BACKUP=$(pwd)

fxTitle "Setting up temp directory..."
WSU_TMP_DIR=/tmp/wsu-wordpress-new/
rm -rf "${WSU_TMP_DIR}"

PROJECT_DIR=${WSU_TMP_DIR}${APP_NAME}/
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"

WEBROOT_DIR=${PROJECT_DIR}public/
fxOK "WEBROOT_DIR is now ##${WEBROOT_DIR}##"

mkdir -p "${WEBROOT_DIR}"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WEBROOT_DIR}"

# https://developer.wordpress.org/cli/commands/core/download/
wsuWordPress core download --locale="${WORDPRESS_LOCALE}"
wsuWordPress core version

## https://developer.wordpress.org/cli/commands/config/create/
wsuWordPress config create \
  --dbname="${MYSQL_DB_NAME}" \
  --dbuser="${MYSQL_USER}" \
  --dbhost="${MYSQL_HOST}" \
  --dbpass="${MYSQL_PASSWORD}" \
  --locale="${WORDPRESS_LOCALE}"
  

fxTitle "Adding extra configs to wp-config.php"
WPINST_FIRST_ADMIN_PASSWORD=$(fxPasswordGenerator)
#WPINST_SITE_DOMAIN=$(echo $SITE_URL | sed 's/https\?:\/\///')
#WPINST_SITE_DOMAIN=${WPINST_SITE_DOMAIN%*/}
WPINST_WP_CONFIG="${WEBROOT_DIR}wp-config.php"
WPINST_WP_CONFIG_EXTRAS_PATH="/usr/local/turbolab.it/webstackup/script/php-pages/wp-config-extras.php"

# Check if the config already contains the search string
if ! grep -q "$WPINST_WP_CONFIG_EXTRAS_PATH" "$WPINST_WP_CONFIG"; then

  WPINST_WP_CONFIG_EXTRAS_INCLUDE="/** 🔥 WordPress extras by WEBSTACKUP **/\\
// https://github.com/TurboLabIt/webstackup/tree/master/script/php-pages/wp-config-extras.php\\
require_once '$WPINST_WP_CONFIG_EXTRAS_PATH';\\"

  sed -i "/\/\* That's all, stop editing/i $WPINST_WP_CONFIG_EXTRAS_INCLUDE" "$WPINST_WP_CONFIG"

  fxOK "Webstackup configuration injected."

else

  fxInfo "Webstackup configuration already exists. Skipping."
fi


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
  --url="${SITE_URL}" \
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
# https://wordpress.org/plugins/google-authenticator/
# https://wordpress.org/plugins/classic-editor/
# https://wordpress.org/plugins/radio-buttons-for-taxonomies/
# https://wordpress.org/plugins/regenerate-thumbnails/
# https://wordpress.org/plugins/wp-fastest-cache/
# https://wordpress.org/plugins/redirection/
# https://wordpress.org/plugins/safe-svg/
# https://wordpress.org/plugins/folders/
# https://wordpress.org/plugins/ultimate-addons-for-contact-form-7/

wsuWordPress plugin install \
  wps-hide-login duracelltomi-google-tag-manager seo-by-rank-math \
  webp-express timber-library \
  google-authenticator classic-editor \
  radio-buttons-for-taxonomies regenerate-thumbnails wp-fastest-cache \
  redirection safe-svg folders ultimate-addons-for-contact-form-7 \
  --activate-network --activate

## https://developer.wordpress.org/cli/commands/plugin/auto-updates/
wsuWordPress plugin auto-updates enable --all


## https://wordpress.org/support/topic/change-admin-url-through-wp-cli/
wsuWordPress option update \
  whl_page "${WORDPRESS_ADMIN_NEW_SLUG}" \
  --skip-plugins --skip-themes

## Enable "Folders" on "Media" only
wsuWordPress option update \
  folders_settings '["attachment"]' --format=json \
  --skip-plugins --skip-themes
 
fxTitle "Preparing ${APP_NAME} theme directory..."
mkdir -p "${WEBROOT_DIR}wp-content/themes/${APP_NAME}"
echo "Put your own theme here. It will be Git-commitable" > "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/readme.md"

fxTitle "Preparing ${APP_NAME} plugin directory..."
mkdir -p "${WEBROOT_DIR}wp-content/plugins/${APP_NAME}"
echo "Put your own plugin here. It will be Git-commitable" > "${WEBROOT_DIR}wp-content/plugins/${APP_NAME}/readme.md"


fxTitle "Adding .gitignore for WordPress..."
## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore_wordpress
curl -o "${PROJECT_DIR}backup/.gitignore_wordpress_temp" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore_wordpress
sed -i "s/my-app/${APP_NAME}/g" "${PROJECT_DIR}backup/.gitignore_wordpress_temp"
echo "" >> "${PROJECT_DIR}.gitignore"
cat "${PROJECT_DIR}backup/.gitignore_wordpress_temp" >> "${PROJECT_DIR}.gitignore"
rm -f "${PROJECT_DIR}backup/.gitignore_wordpress_temp"


fxTitle "Restoring PROJECT_DIR..."
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"

WEBROOT_DIR=${WEBROOT_DIR_BACKUP}
fxOK "WEBROOT_DIR is now ##${WEBROOT_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"


fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"
chmod g+w "${WEBROOT_DIR}" -R


fxTitle "The WordPress instance is ready"
fxMessage "Your admin username is: ${WORDPRESS_ADMIN_USERNAME}"
fxMessage "Your admin password is: ${WPINST_FIRST_ADMIN_PASSWORD}"
echo ""
echo "Please login at ${SITE_URL}${WORDPRESS_ADMIN_NEW_SLUG}"

cd "${CURRENT_DIR_BACKUP}"
