### Create a new Magento project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/magento-install.sh
##
## Based on: https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/composer.html#get-the-metapackage

### Variables:
# APP_NAME=
# PROJECT_DIR=
# SITE_URL=
#
# MAGENTO_MARKET_PUBKEY=
# MAGENTO_MARKET_PRIVKEY=
#
# MYSQL_USER=
# MYSQL_PASSWORD=
# MYSQL_HOST=
# MYSQL_DB_NAME=
#
# MAGENTO_ADMIN_USERNAME=
# MAGENTO_ADMIN_EMAIL=
# MAGENTO_ADMIN_NEW_SLUG=
#
# MAGENTO_LOCALE=
# MAGENTO_CURRENCY=
# MAGENTO_TIMEZONE=

fxHeader "🆕 Magento create-project"
rootCheck


if [ ! -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
fi  

if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ] || [ -z "${SITE_URL}" ] || \
   [ -z "${MAGENTO_MARKET_PUBKEY}" ] || [ -z "${MAGENTO_MARKET_PRIVKEY}" ] \
   [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_DB_NAME}" ] || \
   [ -z "${MAGENTO_ADMIN_USERNAME}" ] || [ -z "${MAGENTO_ADMIN_EMAIL}" ] || [ -z "${MAGENTO_ADMIN_NEW_SLUG}" ] || \
   [ -z "${MAGENTO_LOCALE}" ] || [ -z "${MAGENTO_CURRENCY}" ] || [ -z "${MAGENTO_TIMEZONE}" ] \
   ; then

  catastrophicError "Pimcore installer can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  PROJECT_DIR:             ##${PROJECT_DIR}##
  SITE_URL:                ##${SITE_URL}##
  
  MAGENTO_MARKET_PUBKEY:   ##${MAGENTO_MARKET_PUBKEY}##
  MAGENTO_MARKET_PRIVKEY:  ##${MAGENTO_MARKET_PRIVKEY}##
  
  MYSQL_USER:              ##${MYSQL_USER}##
  MYSQL_PASSWORD:          ##${MYSQL_PASSWORD_HIDDEN}##
  MYSQL_HOST:              ##${MYSQL_HOST}##
  MYSQL_DB_NAME:           ##${MYSQL_DB_NAME}##
  
  MAGENTO_ADMIN_USERNAME:  ##${MAGENTO_ADMIN_USERNAME}##
  MAGENTO_ADMIN_EMAIL:     ##${MAGENTO_ADMIN_EMAIL}##
  MAGENTO_ADMIN_NEW_SLUG:  ##${MAGENTO_ADMIN_NEW_SLUG}##
  
  MAGENTO_LOCALE:          ##${MAGENTO_LOCALE}##
  MAGENTO_CURRENCY:        ##${MAGENTO_CURRENCY}##
  MAGENTO_TIMEZONE:        ##${MAGENTO_TIMEZONE}##"
  exit
fi

PROJECT_DIR_BACKUP=${PROJECT_DIR}
MAGENTO_DIR_BACKUP=${MAGENTO_DIR}
CURRENT_DIR_BACKUP=$(pwd)

fxTitle "Setting up temp directory..."
WSU_TMP_DIR=/tmp/wsu-magento-new/
rm -rf "${WSU_TMP_DIR}"
mkdir -p "${WSU_TMP_DIR}"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WSU_TMP_DIR}"

PROJECT_DIR=${WSU_TMP_DIR}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"

wsuComposer create-project magento/project-community-edition shop --repository-url=https://repo.magento.com/
MAGENTO_DIR=${PROJECT_DIR}shop/
cd "${MAGENTO_DIR}"

MAGEINST_FIRST_ADMIN_PASSWORD=$(fxPasswordGenerator)

wsuMage setup:install \
  --base-url=${SITE_URL} \
  --db-host=${MYSQL_HOST} \
  --db-name=${MYSQL_DB_NAME} \
  --db-user=${MYSQL_USER} \
  --db-password=${MYSQL_PASSWORD} \
  #--admin-firstname=Admin \
  #--admin-lastname=Admin \
  --admin-email="${MAGENTO_ADMIN_EMAIL}" \
  --admin-user="${MAGENTO_ADMIN_USERNAME}" \
  --admin-password=${MAGEINST_FIRST_ADMIN_PASSWORD} \
  --language="${MAGENTO_LOCALE}" \
  --currency="${MAGENTO_CURRENCY}" \
  --timezone="${MAGENTO_TIMEZONE}" \
  --use-rewrites=1 \
  --search-engine=elasticsearch7 \
  --elasticsearch-host=localhost \
  --elasticsearch-port=9200 \
  --backend-frontname="${MAGENTO_ADMIN_NEW_SLUG}"


fxTitle "Restoring PROJECT_DIR"
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"

MAGENTO_DIR=${MAGENTO_DIR_BACKUP}
fxOK "MAGENTO_DIR is now ##${MAGENTO_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"

fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"

#fxTitle "Activate custom/nginx-php-fpm.conf (upstream fastcgi_backend_my-app)..."
#find "${PROJECT_DIR}config/custom" -type f -exec sed -i '/^#include .*\/config\/custom\/nginx-php-fpm.conf/ s/^#//' {} \;

fxTitle "The Magento instance is ready"
fxMessage "Your admin username is: ${MAGENTO_ADMIN_USERNAME}"
fxMessage "Your admin password is: ${MAGEINST_FIRST_ADMIN_PASSWORD}"
echo ""
echo "Please login at ${SITE_URL}${PIMCORE_ADMIN_NEW_SLUG}"

cd "${CURRENT_DIR_BACKUP}"
