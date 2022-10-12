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

if [ -z "${APP_NAME}" ] || [ -z "${WEBROOT_DIR}" ] || [ -z "${PIMCORE_LOCALE}" ] || \
   [ -z "${MYSQL_DB_NAME}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_PASSWORD}" ] || \
   [ -z "${SITE_URL}" ] ||  [ -z "${PIMCORE_SITE_NAME}" ] || \
   [ -z "${PIMCORE_ADMIN_USERNAME}" ] || [ -z "${PIMCORE_ADMIN_NEW_SLUG}" ] \
   ; then

  catastrophicError "Pimcore installer can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  WEBROOT_DIR:             ##${WEBROOT_DIR}##
  PIMCORE_LOCALE:          ##${PIMCORE_LOCALE}##
  MYSQL_DB_NAME:           ##${MYSQL_DB_NAME}##
  MYSQL_USER:              ##${MYSQL_USER}##
  MYSQL_HOST:              ##${MYSQL_HOST}##
  MYSQL_PASSWORD:          ##${MYSQL_PASSWORD}##
  SITE_URL:                ##${SITE_URL}##
  PIMCORE_SITE_NAME:       ##${PIMCORE_SITE_NAME}##
  PIMCORE_ADMIN_USERNAME:  ##${PIMCORE_ADMIN_USERNAME}##
  PIMCORE_ADMIN_NEW_SLUG:  ##${PIMCORE_ADMIN_NEW_SLUG}##"
  exit
fi


PCINST_WEBROOT_DIR=${WEBROOT_DIR%*/}/
PCINST_FIRST_ADMIN_PASSWORD=$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)
PCINST_SITE_DOMAIN=$(echo $SITE_URL | sed 's/https\?:\/\///')
PCINST_SITE_DOMAIN=${PCINST_SITE_DOMAIN%*/}

cd /tmp
rm -rf /tmp/${APP_NAME}
XDEBUG_MODE=off ${PHP_CLI} /usr/local/bin/composer create-project pimcore/skeleton /tmp/${APP_NAME} --no-interaction

shopt -s dotglob
cp -r /tmp/${APP_NAME}/. ${PROJECT_DIR}
rm -rf /tmp/${APP_NAME}

cd ${PROJECT_DIR}
XDEBUG_MODE=off ${PHP_CLI} vendor/bin/pimcore-install \
  --admin-username "${PIMCORE_ADMIN_USERNAME}" --admin-password "${PCINST_FIRST_ADMIN_PASSWORD}" \
  --mysql-host-socket "${MYSQL_HOST}" --mysql-username "${MYSQL_USER}" --mysql-password "${MYSQL_PASSWORD}" --mysql-database "${MYSQL_DB_NAME}" \
  --no-interaction

#fxTitle "Downloading .gitignore"
#curl -o "${PCINST_WEBROOT_DIR}.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore_pimcore?$(date +%s)
#sed -i "s|my-app|${APP_NAME}|g" "${PCINST_WEBROOT_DIR}.gitignore"

fxTitle "Set the permissions"
chown webstackup:www-data ${PCINST_WEBROOT_DIR} -R
chmod u=rwx,g=rwX,o=rX ${PCINST_WEBROOT_DIR} -R

fxMessage "Your admin password is: $PCINST_FIRST_ADMIN_PASSWORD"
