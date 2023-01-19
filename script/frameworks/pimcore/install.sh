### AUTOMATIC PIMCORE SETUP BY WEBSTACK.UP
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

fxHeader "💿 Pimcore installer"
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


PCINST_FIRST_ADMIN_PASSWORD=$(fxPasswordGenerator)
PCINST_SITE_DOMAIN=$(echo $SITE_URL | sed 's/https\?:\/\///')
PCINST_SITE_DOMAIN=${PCINST_SITE_DOMAIN%*/}


function wsuPimcoreInstallComposer()
{
  sudo -u $EXPECTED_USER -H XDEBUG_MODE=off COMPOSER_MEMORY_LIMIT=-1 \
    ${PHP_CLI} /usr/local/bin/composer "$@" --working-dir "${PROJECT_DIR}" --no-interaction
}


fxTitle "Switching to ${PROJECT_DIR}..."
cd ${PROJECT_DIR}
fxOK "$(pwd)"


fxTitle "Composering pimcore/skeleton..."
wsuPimcoreInstallComposer create-project pimcore/skeleton downloaded-pimcore
rsync -a "${PROJECT_DIR}downloaded-pimcore/" "${WSU_MAP_DEPLOY_TO_PATH}/"
rm -rf "${PROJECT_DIR}downloaded-pimcore/"


fxTitle "Adding Symfony bundles..."
wsuPimcoreInstallComposer require symfony/maker-bundle --dev


fxTitle "Running the downloaded Pimcore installer from vendor..."
sudo -u $EXPECTED_USER -H \
  XDEBUG_MODE=off \ 
  PIMCORE_INSTALL_ADMIN_USERNAME=${PIMCORE_ADMIN_USERNAME} \
  PIMCORE_INSTALL_ADMIN_PASSWORD=${PCINST_FIRST_ADMIN_PASSWORD} \
  PIMCORE_INSTALL_MYSQL_USERNAME=${MYSQL_USER} \
  PIMCORE_INSTALL_MYSQL_PASSWORD=${MYSQL_PASSWORD} \
  ${PHP_CLI} vendor/bin/pimcore-install \
    --mysql-host-socket "${MYSQL_HOST}" --mysql-database "${MYSQL_DB_NAME}" \
    --no-interaction

#fxTitle "Downloading .gitignore"
#curl -o "${PCINST_WEBROOT_DIR}.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore_pimcore?$(date +%s)
#sed -i "s|my-app|${APP_NAME}|g" "${PCINST_WEBROOT_DIR}.gitignore"

#fxTitle "Set the permissions"
#chown webstackup:www-data ${PCINST_WEBROOT_DIR} -R
#chmod u=rwx,g=rwX,o=rX ${PCINST_WEBROOT_DIR} -R

fxTitle "The Pimcore instance is ready"
fxMessage "Your admin username is: ${PIMCORE_ADMIN_USERNAME}"
fxMessage "Your admin password is: ${PCINST_FIRST_ADMIN_PASSWORD}"
echo ""
echo "Please login at https://${PCINST_SITE_DOMAIN}/${PIMCORE_ADMIN_NEW_SLUG}"

