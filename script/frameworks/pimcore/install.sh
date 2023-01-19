### AUTOMATIC PIMCORE SETUP BY WEBSTACK.UP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/pimcore-install.sh

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
  sudo -u $EXPECTED_USER -H XDEBUG_MODE=off ${PHP_CLI} \
    /usr/local/bin/composer "$@" --working-dir "${PROJECT_DIR}" --no-interaction
}


fxTitle "Switching to ${PROJECT_DIR}..."
cd ${PROJECT_DIR}
fxOK "$(pwd)"


fxTitle "Composering pimcore/skeleton..."
wsuPimcoreInstallComposer create-project pimcore/skeleton


fxTitle "Adding Symfony bundles..."
wsuPimcoreInstallComposer require symfony/maker-bundle --dev


fxTitle "Running the downloaded Pimcore installer from vendor..."
sudo -u $EXPECTED_USER -H XDEBUG_MODE=off ${PHP_CLI} \
  vendor/bin/pimcore-install \
    --admin-username "${PIMCORE_ADMIN_USERNAME}" --admin-password "${PCINST_FIRST_ADMIN_PASSWORD}" \
    --mysql-host-socket "${MYSQL_HOST}" --mysql-username "${MYSQL_USER}" --mysql-password "${MYSQL_PASSWORD}" --mysql-database "${MYSQL_DB_NAME}" \
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

