### Create a new Magento project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/magento-install.sh
##
## Based on: https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/composer.html#get-the-metapackage

### Variables:

fxHeader "🆕 pimcore create-project"
rootCheck




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
  --backend-frontname="${WORDPRESS_ADMIN_NEW_SLUG}"


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
