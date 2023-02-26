### Create a new Pimcore project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/pimcore-install.sh
##
## Based on: https://pimcore.com/docs/pimcore/current/Development_Documentation/Getting_Started/Installation.html

### Variables:
# WEBROOT_DIR=
# EXPECTED_USER=

# MYSQL_DB_NAME=
# MYSQL_USER=
# MYSQL_HOST=
# MYSQL_PASSWORD=
# 
# SITE_URL=
# PIMCORE_SITE_NAME="🚀 Pimcore"
# PIMCORE_LOCALE=it_IT

# PIMCORE_ADMIN_USERNAME=
# PIMCORE_ADMIN_NEW_SLUG=


fxHeader "💿 pimcore create-project"
rootCheck


if [ ! -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
fi  

if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ] || [ -z "${PIMCORE_LOCALE}" ] || \
   [ -z "${MYSQL_DB_NAME}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_PASSWORD}" ] || \
   [ -z "${SITE_URL}" ] ||  [ -z "${PIMCORE_SITE_NAME}" ] || \
   [ -z "${PIMCORE_ADMIN_USERNAME}" ] || [ -z "${PIMCORE_ADMIN_NEW_SLUG}" ] \
   ; then

  catastrophicError "Pimcore installer can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  PROJECT_DIR:             ##${PROJECT_DIR}##
  PIMCORE_LOCALE:          ##${PIMCORE_LOCALE}##
  MYSQL_DB_NAME:           ##${MYSQL_DB_NAME}##
  MYSQL_USER:              ##${MYSQL_USER}##
  MYSQL_HOST:              ##${MYSQL_HOST}##
  MYSQL_PASSWORD:          ##${MYSQL_PASSWORD_HIDDEN}##
  SITE_URL:                ##${SITE_URL}##
  PIMCORE_SITE_NAME:       ##${PIMCORE_SITE_NAME}##
  PIMCORE_ADMIN_USERNAME:  ##${PIMCORE_ADMIN_USERNAME}##
  PIMCORE_ADMIN_NEW_SLUG:  ##${PIMCORE_ADMIN_NEW_SLUG}##"
  exit
fi


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


PCINST_FIRST_ADMIN_PASSWORD=$(fxPasswordGenerator)
PCINST_SITE_DOMAIN=$(echo $SITE_URL | sed 's/https\?:\/\///')
PCINST_SITE_DOMAIN=${PCINST_SITE_DOMAIN%*/}


wsuComposer create-project pimcore/skeleton ${APP_NAME}


wsuComposer require symfony/maker-bundle symfony/debug-pack --dev


fxTitle "Adding TurboLab.it packages..."
# https://github.com/TurboLabIt/php-foreachable
wsuComposer config repositories.turbolabit/php-foreachable git https://github.com/TurboLabIt/php-foreachable.git
wsuComposer require turbolabit/php-foreachable:dev-main

# https://github.com/TurboLabIt/php-symfony-basecommand
wsuComposer config repositories.turbolabit/php-symfony-basecommand git https://github.com/TurboLabIt/php-symfony-basecommand.git
wsuComposer require turbolabit/php-symfony-basecommand:dev-main


fxTitle "Running the downloaded Pimcore installer from vendor..."
sudo -u $EXPECTED_USER -H XDEBUG_MODE=off \ 
  PIMCORE_INSTALL_ADMIN_USERNAME="${PIMCORE_ADMIN_USERNAME}" \
  PIMCORE_INSTALL_ADMIN_PASSWORD="${PCINST_FIRST_ADMIN_PASSWORD}" \
  PIMCORE_INSTALL_MYSQL_USERNAME="${MYSQL_USER}" \
  PIMCORE_INSTALL_MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
  ${PHP_CLI} vendor/bin/pimcore-install \
  --mysql-host-socket "${MYSQL_HOST}" --mysql-database "${MYSQL_DB_NAME}" \
  --no-interaction


fxTitle "Adding .gitignore..."
curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore


fxTitle "Restoring PROJECT_DIR"
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"


fxTitle "👮 Setting permissions..."
chmod ugo= "${PROJECT_DIR}" -R
chmod u=rwx,go=rX "${PROJECT_DIR}" -R
chmod go=rwX "${PROJECT_DIR}var" -R

fxTitle "👮 Setting the owner..."
chown ${EXPECTED_USER}:www-data "${PROJECT_DIR}" -R


fxTitle "📂 Listing PROJECT_DIR ##${PROJECT_DIR}#"
ls -la --color=always "${PROJECT_DIR}"


fxTitle "The Pimcore instance is ready"
fxMessage "Your admin username is: ${PIMCORE_ADMIN_USERNAME}"
fxMessage "Your admin password is: ${PCINST_FIRST_ADMIN_PASSWORD}"
echo ""
echo "Please login at https://${PCINST_SITE_DOMAIN}/${PIMCORE_ADMIN_NEW_SLUG}"

cd "${CURRENT_DIR_BACKUP}"
