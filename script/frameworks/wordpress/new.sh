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

fxTitle "Downloading WordPress..."
# https://developer.wordpress.org/cli/commands/core/download/
wsuWordPress core download --locale="${WORDPRESS_LOCALE}"


fxTitle "Generating wp-config.php..."
## https://developer.wordpress.org/cli/commands/config/create/
wsuWordPress config create \
  --dbname="${MYSQL_DB_NAME}" \
  --dbuser="${MYSQL_USER}" \
  --dbhost="${MYSQL_HOST}" \
  --dbpass="${MYSQL_PASSWORD}" \
  --locale="${WORDPRESS_LOCALE}"
  

fxTitle "Computing additional parameters..."
WPINST_FIRST_ADMIN_PASSWORD=$(fxPasswordGenerator)
#WPINST_SITE_DOMAIN=$(echo $SITE_URL | sed 's/https\?:\/\///')
#WPINST_SITE_DOMAIN=${WPINST_SITE_DOMAIN%*/}


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


fxTitle "Installing WordPress..."
wsuWordPress core $WPINST_WORDPRESS_INSTALL_MODE $WPINST_WORDPRESS_MULTISITE_MODE_ARGUMENT \
  --url="${SITE_URL}" \
  --title="${WORDPRESS_SITE_NAME}" \
  --admin_user="${WORDPRESS_ADMIN_USERNAME}" \
  --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
  --admin_password="${WPINST_FIRST_ADMIN_PASSWORD}" \
  --skip-email


fxTitle "Remove the built-in plugins..."
wsuWordPress plugin uninstall akismet hello --deactivate


fxTitle "Installing additional plugins..."
if [ "$WORDPRESS_SKIP_EXTRA_PLUGINS_INSTALL" != 1 ]; then

  ## https://developer.wordpress.org/cli/commands/plugin/install/
  # https://wordpress.org/plugins/wps-hide-login/
  # https://wordpress.org/plugins/duracelltomi-google-tag-manager/
  # https://wordpress.org/plugins/seo-by-rank-math/
  # https://wordpress.org/plugins/webp-express/
  # https://wordpress.org/plugins/google-authenticator/
  # https://wordpress.org/plugins/classic-editor/
  # https://wordpress.org/plugins/radio-buttons-for-taxonomies/
  # https://wordpress.org/plugins/regenerate-thumbnails/
  # https://wordpress.org/plugins/wp-fastest-cache/
  # https://wordpress.org/plugins/redirection/
  # https://wordpress.org/plugins/safe-svg/
  # https://wordpress.org/plugins/folders/
  # https://wordpress.org/plugins/ultimate-addons-for-contact-form-7/
  # https://wordpress.org/plugins/better-search-replace/

  wsuWordPress plugin install \
    wps-hide-login duracelltomi-google-tag-manager seo-by-rank-math \
    webp-express \
    google-authenticator classic-editor \
    radio-buttons-for-taxonomies regenerate-thumbnails wp-fastest-cache \
    redirection safe-svg folders ultimate-addons-for-contact-form-7 \
    better-search-replace \
    --activate-network --activate

  fxTitle "Activating plugins auto-update..."
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

else

  fxInfo "Skipped (disabled in config) 🦘"
fi


fxTitle "Preparing ${APP_NAME} theme directory..."
mkdir -p "${WEBROOT_DIR}wp-content/themes/${APP_NAME}"
cd "${WEBROOT_DIR}wp-content/themes/${APP_NAME}"

echo "/*
  Theme Name: ${APP_NAME}
*/" > "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/style.css"

echo "<?php" > "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/index.php"
echo "<?php" > "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/functions.php"


## package and webpack
cp "${WEBSTACKUP_SCRIPT_DIR}node.js/package-webpack-extract-css.json" "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/package.json"

cat <<EOF > "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/webpack.config.js"
const sharedConfig = require('/usr/local/turbolab.it/webstackup/script/node.js/webpack-extract-css.config.js');
module.exports = sharedConfig;
EOF

mkdir -p "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/assets/js"
cat <<EOF > "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/assets/js/main.js"
import * as bootstrap from 'bootstrap';
window.bootstrap = bootstrap;
EOF


mkdir -p "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/assets/scss"
cat <<EOF > "${WEBROOT_DIR}wp-content/themes/${APP_NAME}/assets/scss/style.scss"
@use "bootstrap/scss/bootstrap" as bootstrap;
EOF


fxTitle "Adding packages via composer to my theme..."
function wsuComposerWp()
{
  COMPOSER=composer.json XDEBUG_MODE=off COMPOSER_MEMORY_LIMIT=-1 COMPOSER_ALLOW_SUPERUSER=1 \
    ${PHP_CLI} /usr/local/bin/composer \
    --working-dir="${WEBROOT_DIR}wp-content/themes/${APP_NAME}" \
    "$@" \
    --no-interaction
}

## 📚 https://timber.github.io/docs/v2/installation/installation/
wsuComposerWp require timber/timber:@stable


fxList "${WEBROOT_DIR}wp-content/themes/${APP_NAME}"


fxTitle "Enabling my own ##${APP_NAME}## theme..."
wsuWordPress theme activate "${APP_NAME}"

fxTitle "Deleting the other, bundled themes..."
WSU_WPCLI_DEBUG_MODE=0 wsuWordPress theme list --status=inactive --field=name | \
  while read -r theme; do
    if [[ -n "$theme" ]]; then
      wsuWordPress theme delete "$theme"
    fi
  done


fxTitle "Deleting the sample content..."
wsuWordPress comment delete 1 --force
wsuWordPress post delete 1 --force


fxTitle "Disabling comments and pingbacks by default..."
wsuWordPress option update default_comment_status closed
wsuWordPress option update default_ping_status closed


fxTitle "Preparing ${APP_NAME} plugin directory..."
cd "${WEBROOT_DIR}"
mkdir -p "${WEBROOT_DIR}wp-content/plugins/${APP_NAME}"
echo "Put your own plugin here" > "${WEBROOT_DIR}wp-content/plugins/${APP_NAME}/readme.md"


## https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/wordpress/pre-deploy.sh
source "/usr/local/turbolab.it/webstackup/script/frameworks/wordpress/pre-deploy.sh"


fxTitle "Restoring PROJECT_DIR..."
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"

WEBROOT_DIR=${WEBROOT_DIR_BACKUP}
fxOK "WEBROOT_DIR is now ##${WEBROOT_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"


fxTitle "Adding .gitignore for WordPress..."
## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore_wordpress
if ! grep -q "### WordPress webdev-gitignore" "${PROJECT_DIR}.gitignore"; then

  curl -o "${PROJECT_DIR}.gitignore_wordpress_temp" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore_wordpress
  sed -i "s/my-app/${APP_NAME}/g" "${PROJECT_DIR}.gitignore_wordpress_temp"
  echo "" >> "${PROJECT_DIR}.gitignore"
  cat "${PROJECT_DIR}.gitignore_wordpress_temp" >> "${PROJECT_DIR}.gitignore"
  rm -f "${PROJECT_DIR}.gitignore_wordpress_temp"

else

  fxInfo "Skipped (.gitignore for WordPress is already there) 🦘"
fi


fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"
chmod g+w "${WEBROOT_DIR}" -R


fxTitle "The WordPress instance is ready"
fxMessage "Your admin username is: ${WORDPRESS_ADMIN_USERNAME}"
fxMessage "Your admin password is: ${WPINST_FIRST_ADMIN_PASSWORD}"
echo ""
echo "Please login at ${SITE_URL}${WORDPRESS_ADMIN_NEW_SLUG}"

cd "${CURRENT_DIR_BACKUP}"
