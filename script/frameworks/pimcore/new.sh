### Create a new Pimcore project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/pimcore-install.sh
##
## Based on: https://pimcore.com/docs/pimcore/current/Development_Documentation/Getting_Started/Installation.html

### Variables:
# APP_NAME
# PROJECT_DIR
# SITE_URL
#
# MYSQL_USER
# MYSQL_PASSWORD
# MYSQL_HOST
# MYSQL_DB_NAME
#
# PIMCORE_ADMIN_USERNAME
# PIMCORE_ADMIN_NEW_SLUG
# PIMCORE_LOCALE

fxHeader "🆕 pimcore create-project"
rootCheck


if [ ! -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
fi  

if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ] || [ -z "${SITE_URL}" ] || \
   [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_DB_NAME}" ] || \
   [ -z "${PIMCORE_ADMIN_USERNAME}" ] || [ -z "${PIMCORE_ADMIN_NEW_SLUG}" ] || [ -z "${PIMCORE_LOCALE}" ] \
   ; then

  catastrophicError "Pimcore installer can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  PROJECT_DIR:             ##${PROJECT_DIR}##
  SITE_URL:                ##${SITE_URL}##

  MYSQL_USER:              ##${MYSQL_USER}##
  MYSQL_PASSWORD:          ##${MYSQL_PASSWORD_HIDDEN}##
  MYSQL_HOST:              ##${MYSQL_HOST}##
  MYSQL_DB_NAME:           ##${MYSQL_DB_NAME}##

  PIMCORE_ADMIN_USERNAME:  ##${PIMCORE_ADMIN_USERNAME}##
  PIMCORE_ADMIN_NEW_SLUG:  ##${PIMCORE_ADMIN_NEW_SLUG}##"
  PIMCORE_LOCALE:          ##${PIMCORE_LOCALE}##
  exit
fi


fxTitle "💿 Intalling pre-requisites..."
sudo apt install php${PHP_VER}-amqp -y


PROJECT_DIR_BACKUP=${PROJECT_DIR}
CURRENT_DIR_BACKUP=$(pwd)

fxTitle "Setting up temp directory..."
WSU_TMP_DIR=/tmp/wsu-pimcore-new/
rm -rf "${WSU_TMP_DIR}"
mkdir -p "${WSU_TMP_DIR}"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WSU_TMP_DIR}"

PROJECT_DIR=${WSU_TMP_DIR}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"


wsuComposer create-project pimcore/skeleton:2024.4 ${APP_NAME}
cd "${APP_NAME}"

wsuComposer config minimum-stability dev


PCINST_FIRST_ADMIN_PASSWORD=$(fxPasswordGenerator)

fxTitle "Running the downloaded Pimcore installer from vendor..."
sudo -u $EXPECTED_USER -H XDEBUG_MODE=off \
  PIMCORE_INSTALL_ADMIN_USERNAME="${PIMCORE_ADMIN_USERNAME}" \
  PIMCORE_INSTALL_ADMIN_PASSWORD="${PCINST_FIRST_ADMIN_PASSWORD}" \
  PIMCORE_INSTALL_MYSQL_USERNAME="${MYSQL_USER}" \
  PIMCORE_INSTALL_MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
  ${PHP_CLI} vendor/bin/pimcore-install \
  --mysql-host-socket "${MYSQL_HOST}" --mysql-database "${MYSQL_DB_NAME}" \
  --no-interaction

wsuComposer require symfony/maker-bundle symfony/debug-pack --dev
wsuComposer require turbolabit/php-foreachable:dev-main turbolabit/php-symfony-basecommand:dev-main

wsuSymfony console pimcore:bundle:install PimcoreSimpleBackendSearchBundle
wsuSymfony console pimcore:search-backend-reindex


fxTitle "Adding .gitignore..."
## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore
curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore

## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore_pimcore
curl -o "${PROJECT_DIR}backup/.gitignore_pimcore_temp" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore_pimcore
sed -i "s/my-app/${APP_NAME}/g" "${PROJECT_DIR}backup/.gitignore_pimcore_temp"
echo "" >> "${PROJECT_DIR}.gitignore"
cat "${PROJECT_DIR}backup/.gitignore_pimcore_temp" >> "${PROJECT_DIR}.gitignore"
rm -f "${PROJECT_DIR}backup/.gitignore_pimcore_temp"


fxTitle "Restoring PROJECT_DIR"
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"

fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"

fxTitle "Activate custom/nginx-php-fpm.conf (upstream fastcgi_backend_my-app)..."
find "${PROJECT_DIR}config/custom" -type f -exec sed -i '/^#include .*\/config\/custom\/nginx-php-fpm.conf/ s/^#//' {} \;

fxTitle "The Pimcore instance is ready"
fxMessage "Your admin username is: ${PIMCORE_ADMIN_USERNAME}"
fxMessage "Your admin password is: ${PCINST_FIRST_ADMIN_PASSWORD}"
echo ""
echo "Please login at ${SITE_URL}${PIMCORE_ADMIN_NEW_SLUG}"

cd "${CURRENT_DIR_BACKUP}"
