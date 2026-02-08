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
# ELASTICSEARCH_HOST=
#
# MAGENTO_ADMIN_USERNAME=
# MAGENTO_ADMIN_EMAIL=
# MAGENTO_ADMIN_NEW_SLUG=
#
# MAGENTO_LOCALE=
# MAGENTO_CURRENCY=
# MAGENTO_TIMEZONE=
# MAGENTO_VERSION=

fxHeader "🆕 Magento create-project"
rootCheck


if [ ! -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
fi

if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ] || [ -z "${SITE_URL}" ] || \
   [ -z "${MAGENTO_MARKET_PUBKEY}" ] || [ -z "${MAGENTO_MARKET_PRIVKEY}" ] || \
   [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_DB_NAME}" ] || \
   [ -z "${ELASTICSEARCH_HOST}" ] ||
   [ -z "${MAGENTO_ADMIN_USERNAME}" ] || [ -z "${MAGENTO_ADMIN_EMAIL}" ] || [ -z "${MAGENTO_ADMIN_NEW_SLUG}" ] || \
   [ -z "${MAGENTO_LOCALE}" ] || [ -z "${MAGENTO_CURRENCY}" ] || [ -z "${MAGENTO_TIMEZONE}" ] \
   ; then

  catastrophicError "Magento installer can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  PROJECT_DIR:             ##${PROJECT_DIR}##
  SITE_URL:                ##${SITE_URL}##

  MAGENTO_MARKET_PUBKEY:   ##${MAGENTO_MARKET_PUBKEY}##
  MAGENTO_MARKET_PRIVKEY:  ##${MAGENTO_MARKET_PRIVKEY}##

  MYSQL_USER:              ##${MYSQL_USER}##
  MYSQL_PASSWORD:          ##${MYSQL_PASSWORD_HIDDEN}##
  MYSQL_HOST:              ##${MYSQL_HOST}##
  MYSQL_DB_NAME:           ##${MYSQL_DB_NAME}##

  ELASTICSEARCH_HOST:      ##${ELASTICSEARCH_HOST}##

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
COMPOSER_JSON_FULLPATH=

PROJECT_DIR=${WSU_TMP_DIR}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"


fxTitle "Magento version check..."
if [ -z "${MAGENTO_VERSION}" ]; then

  fxInfo "No specific version of Magento requested (good!) - I'm going to install the latest"

else

  fxWarning "Magento ver. ${MAGENTO_VERSION} requested"
  MAGENTO_INSTALL_COMPOSER_SWITCHES="--no-audit --no-security-blocking"
fi

MAGENTO_INSTALL_COMPOSER_SWITCHES="--ignore-platform-reqs ${MAGENTO_INSTALL_COMPOSER_SWITCHES}"


wsuComposer create-project magento/project-community-edition=${MAGENTO_VERSION} ${APP_NAME} \
  --repository-url=https://${MAGENTO_MARKET_PUBKEY}:${MAGENTO_MARKET_PRIVKEY}@repo.magento.com/ \
  ${MAGENTO_INSTALL_COMPOSER_SWITCHES}

MAGENTO_DIR=${PROJECT_DIR}${APP_NAME}/
fxOK "MAGENTO_DIR is now ##${MAGENTO_DIR}##"
cd "${MAGENTO_DIR}"

wsuComposer config http-basic.repo.magento.com "${MAGENTO_MARKET_PUBKEY}" "${MAGENTO_MARKET_PRIVKEY}"
wsuComposer config http-basic.composer.amasty.com "wsuMapReplaceWithPubKey" "wsuMapReplaceWithPRivKey"
wsuComposer config http-basic.magefan.com "wsuMapReplaceWithPubKey" "wsuMapReplaceWithPRivKey"

## workaround laminas
rm -f "${MAGENTO_DIR}composer.lock"
wsuComposer update ${MAGENTO_INSTALL_COMPOSER_SWITCHES}

wsuComposer require magento/quality-patches ${MAGENTO_INSTALL_COMPOSER_SWITCHES}


fxTitle "Rename fastcgi_backend in nginx.conf.sample..."
sed -i "s| fastcgi_backend;| fastcgi_backend_${APP_NAME};|g" ${MAGENTO_DIR}nginx.conf.sample


fxTitle "Generating admin password..."
MAGEINST_FIRST_ADMIN_PASSWORD=$(fxPasswordGenerator)


## workaround for "Invalid backend frontname"
MAGENTO_ADMIN_NEW_SLUG=$(fxAlphanumOnly "${MAGENTO_ADMIN_NEW_SLUG}")


fxTitle "Restarting OpenSearch..."
if [ "${ELASTICSEARCH_HOST}" = "localhost" ] || [ "${ELASTICSEARCH_HOST}" = "localhost" ]; then

  ## workaround for https://magento.stackexchange.com/q/366082/50130
  sudo sed -i 's/plugins.security.disabled: false/plugins.security.disabled: true/' /etc/opensearch/opensearch.yml
  service opensearch restart

else

  fxWarning "OpenSearch is not on localhost, skipping 🦘"
fi

source /etc/turbolab.it/opensearch.conf

## 📚 https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/advanced#install-from-the-command-line
wsuMage setup:install \
  --base-url=${SITE_URL} \
  --db-host=${MYSQL_HOST} \
  --db-name=${MYSQL_DB_NAME} \
  --db-user=${MYSQL_USER} \
  --db-password=${MYSQL_PASSWORD} \
  --admin-firstname=$(logname) \
  --admin-lastname=$(logname) \
  --admin-email="${MAGENTO_ADMIN_EMAIL}" \
  --admin-user="${MAGENTO_ADMIN_USERNAME}" \
  --admin-password=${MAGEINST_FIRST_ADMIN_PASSWORD} \
  --language="${MAGENTO_LOCALE}" \
  --currency="${MAGENTO_CURRENCY}" \
  --timezone="${MAGENTO_TIMEZONE}" \
  --use-rewrites=1 \
  --opensearch-host=${ELASTICSEARCH_HOST} \
  --opensearch-port=9210 \
  --opensearch-enable-auth=true \
  --opensearch-username=wsu_app \
  --opensearch-password="${OPENSEARCH_USER_PASSWORD}" \
  --backend-frontname="${MAGENTO_ADMIN_NEW_SLUG}"


fxTitle "Restoring PROJECT_DIR"
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"

MAGENTO_DIR=${MAGENTO_DIR_BACKUP}
fxOK "MAGENTO_DIR is now ##${MAGENTO_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}shop/##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}shop"
rm -rf "${WSU_TMP_DIR}"

fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"
fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}shop"

fxTitle "Activate custom/nginx-php-fpm.conf (upstream fastcgi_backend_my-app)..."
find "${PROJECT_DIR}config/custom" -type f -exec sed -i '/^#include .*\/config\/custom\/nginx-php-fpm.conf/ s/^#//' {} \;

cd ${PROJECT_DIR}
rm -rf "${PROJECT_DIR}shop/var/di/"*
wsuMage setup:upgrade
wsuMage setup:di:compile
bash "${PROJECT_DIR}scripts/cache-clear.sh"


fxTitle "The Magento instance is ready"
fxMessage "Your admin username is: ${MAGENTO_ADMIN_USERNAME}"
fxMessage "Your admin password is: ${MAGEINST_FIRST_ADMIN_PASSWORD}"
echo ""
echo "Please login at ${SITE_URL}${MAGENTO_ADMIN_NEW_SLUG}"

cd "${CURRENT_DIR_BACKUP}"
