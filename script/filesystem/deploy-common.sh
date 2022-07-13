### MANAGED FILES ###
#####################

# ${PROJECT_DIR}composer.json
# ${WEBROOT_DIR}composer.json

# ${SCRIPT_DIR}deploy.sh
# USE_SYMFONY_CLEARCACHE
# ${SCRIPT_DIR}cache-clear.sh
# ${SCRIPT_DIR}test_runner.sh
# ${SCRIPT_DIR}migrate.sh
# USE_NGINX_MAINTENANCE
# ${SCRIPT_DIR}maintenance.sh

# ${SCRIPT_DIR}zzcd_bookmarks.sh

# ${PROJECT_DIR}config/custom/cron
# ${PROJECT_DIR}config/custom/${APP_ENV}/cron

# ${PROJECT_DIR}config/custom/php-custom.ini
# ${PROJECT_DIR}config/custom/php-custom-fpm.ini
# ${PROJECT_DIR}config/custom/php-custom-cli.ini

# ${PROJECT_DIR}config/custom/mysql-custom.conf

# ${PROJECT_DIR}config/custom/logrotate.conf

# ${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf

# AUTODEPLOY (work in progress...)

# bash ${USERS_TEMPLATE_PATH}
# bash ${USERS_TEMPLATE_PATH_STAGING}

# ${PROJECT_DIR}config/custom/zzmysqldump-deploy.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump-deploy.conf

# ${PROJECT_DIR}config/custom/zzfirewall-whitelist.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall-whitelist.conf


echo ""
echo -e "\e[1;46m ============= \e[0m"
echo -e "\e[1;46m DEPLOY-COMMON \e[0m"
echo -e "\e[1;46m ============= \e[0m"

if [ "${APP_ENV}" != 'prod' ] && [ "${APP_ENV}" != 'staging' ]; then
  catastrophicError "Common deploy ops can't run in this APP_ENV (##${APP_ENV}##)"
  exit
fi

if [ -z "${APP_NAME}" ] || [ -z "${EXPECTED_USER}" ] || [ -z "${PHP_VER}" ] ||  [ -z "${PROJECT_DIR}" ] || [ -z "${SCRIPT_DIR}" ]; then

  catastrophicError "Common deploy ops can't run with these variables undefined:
  
  APP_NAME:       ##${APP_NAME}##
  EXPECTED_USER:  ##${EXPECTED_USER}##
  PHP_VER:        ##${PHP_VER}##
  PROJECT_DIR:    ##${PROJECT_DIR}##
  SCRIPT_DIR:     ##${SCRIPT_DIR}##"
  exit
fi

##
printTitle "#️⃣ Pre-pull hashing"
echo "Hashing the sourcing script ##${0}##"
DEPLOY_SCRIPT_PREPULL_HASH=`md5sum $0 | awk '{ print $1 }'`
echo "Hash: $DEPLOY_SCRIPT_PREPULL_HASH"

## pulling and merging
printTitle "⏬ Git pulling..."
sudo -u ${EXPECTED_USER} -H git config --global --add safe.directory "${PROJECT_DIR}"
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" reset --hard
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" pull
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" gc --aggressive

printTitle "#️⃣ Post-pull hashing"
echo "Hashing the sourcing script ##${0}##"
DEPLOY_SCRIPT_POSTPULL_HASH=`md5sum $0 | awk '{ print $1 }'`
echo "Hash: $DEPLOY_SCRIPT_POSTPULL_HASH"

if [ "${DEPLOY_SCRIPT_PREPULL_HASH}" != "${DEPLOY_SCRIPT_POSTPULL_HASH}" ] && [ ! -z "${LOCKFILE}" ]; then
  rm -f "${LOCKFILE}"
fi

if [ "${DEPLOY_SCRIPT_PREPULL_HASH}" != "${DEPLOY_SCRIPT_POSTPULL_HASH}" ]; then

  catastrophicError "The deploy script has been updated by the pull! Please run it again!"
  exit
fi


## cleanup
printTitle "🧹 Cleaning up..."
rm -rf /tmp/.symfony


## composer
if [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${PROJECT_DIR}composer.json" ]; then

  COMPOSER_JSON_FULLPATH=${PROJECT_DIR}composer.json

elif [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${WEBROOT_DIR}composer.json" ]; then

  COMPOSER_JSON_FULLPATH=${WEBROOT_DIR}composer.json
fi

if [ ! -z "${COMPOSER_JSON_FULLPATH}" ]; then

  printTitle "📦 Removing composer dump-autoload..."
  rm -f "$(dirname ${COMPOSER_JSON_FULLPATH})/vendor/composer/autoload_classmap.php"

  printTitle "📦 Composer install from ##${COMPOSER_JSON_FULLPATH}##..."
  sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" /usr/bin/php${PHP_VER} /usr/local/bin/composer install --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})" --no-dev --no-interaction
  sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" /usr/bin/php${PHP_VER} /usr/local/bin/composer dump-env ${APP_ENV} --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})" --no-interaction
  
fi

if [ ! -z "${COMPOSER_JSON_FULLPATH}" ] && [ "${COMPOSER_SKIP_DUMP_AUTOLOAD}" != 1 ]; then

  printTitle "📦 Composer dump-autoload..."
  sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" /usr/bin/php${PHP_VER} /usr/local/bin/composer dump-autoload --classmap-authoritative --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})" --no-dev --no-interaction

fi


## zzdeploy global command
if [ -f "${SCRIPT_DIR}deploy.sh" ] && [ ! -z "${ZZDEPLOY_NAME}" ] && [ ! -f "/usr/local/bin/${ZZDEPLOY_NAME}" ]; then

  printTitle "⚙️ Linking zzdeploy (${ZZDEPLOY_NAME})..."
  ln -s "${SCRIPT_DIR}deploy.sh" "/usr/local/bin/${ZZDEPLOY_NAME}"
  
elif [ -f "${SCRIPT_DIR}deploy.sh" ] && [ ! -f "/usr/local/bin/zzdeploy" ]; then

  printTitle "⚙️ Linking zzdeploy..."
  ln -s "${SCRIPT_DIR}deploy.sh" "/usr/local/bin/zzdeploy"
fi

## zzcache global command
if [ "${USE_SYMFONY_CLEARCACHE}" = 1 ]; then
  printTitle "💫 Copying Symfony clear-cache.sh from webstackup..."
  cp -p "${WEBSTACKUP_SCRIPT_DIR}frameworks/symfony/cache-clear.sh" "${SCRIPT_DIR}"
fi

if [ -f "${SCRIPT_DIR}cache-clear.sh" ] && [ ! -f "/usr/local/bin/zzcache" ]; then
  printTitle "⚙️ Linking zzcache..."
  ln -s "${SCRIPT_DIR}cache-clear.sh" "/usr/local/bin/zzcache"
fi

## zzmaintenance global command
if [ "${USE_NGINX_MAINTENANCE}" = 1 ]; then
  printTitle "💫 Copying Nginx maintenance.sh from webstackup..."
  cp -p "${WEBSTACKUP_SCRIPT_DIR}nginx/maintenance.sh" "${SCRIPT_DIR}"
fi

if [ -f "${SCRIPT_DIR}maintenance.sh" ] && [ ! -f "/usr/local/bin/zzmaintenance" ]; then
  printTitle "⚙️ Linking zzmaintenance..."
  ln -s "${SCRIPT_DIR}maintenance.sh" "/usr/local/bin/zzmaintenance"
fi

## zztest global command
if [ -f "${SCRIPT_DIR}test-runner.sh" ] && [ ! -f "/usr/local/bin/zztest" ]; then
  printTitle "⚙️ Linking zztest..."
  ln -s "${SCRIPT_DIR}test_runner.sh" "/usr/local/bin/zztest"
fi

## zzcd bookmarks
if [ -f "${SCRIPT_DIR}zzcd_bookmarks.sh" ]; then
  printTitle "📂 Linking zzcd config..."
  rm -f "/etc/turbolab.it/zzcd_bookmarks.sh"
  ln -s "${SCRIPT_DIR}zzcd_bookmarks.sh" "/etc/turbolab.it/zzcd_bookmarks.sh"
fi

## cron
if [ -f "${PROJECT_DIR}config/custom/cron" ]; then
  printTitle "⏲️ Copying shared cron file..."
  cp "${PROJECT_DIR}config/custom/cron" "/etc/cron.d/${APP_NAME}"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/cron" ]; then
  printTitle "⏲️ Copying ${APP_ENV} cron file..."
  cp "${PROJECT_DIR}config/custom/${APP_ENV}/cron" "/etc/cron.d/${APP_NAME}_${APP_ENV}"
fi

printTitle "🔃️ Restarting cron..."
echo "/etc/cron.d/"
ls -la "/etc/cron.d/"
service cron restart

## php-custom for php-fpm
if [ -f "${PROJECT_DIR}config/custom/php-custom.ini" ] && [ ! -f "/etc/php/${PHP_VER}/fpm/conf.d/90-${APP_NAME}.ini" ]; then
  printTitle "📜 Linking php-custom from fpm..."
  ln -s "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/fpm/conf.d/90-${APP_NAME}.ini"
fi

## php-custom for php-cli
if [ -f "${PROJECT_DIR}config/custom/php-custom.ini" ] && [ ! -f "/etc/php/${PHP_VER}/cli/conf.d/90-${APP_NAME}.ini" ]; then
  printTitle "📜 Linking php-custom from cli..."
  ln -s "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/cli/conf.d/90-${APP_NAME}.ini"
fi

## php-custom (specific) for php-fpm
if [ -f "${PROJECT_DIR}config/custom/php-custom-fpm.ini" ] && [ ! -f "/etc/php/${PHP_VER}/fpm/conf.d/95-${APP_NAME}-fpm.ini" ]; then
  printTitle "📜 Linking php-custom-fpm..."
  ln -s "${PROJECT_DIR}config/custom/php-custom-fpm.ini" "/etc/php/${PHP_VER}/fpm/conf.d/95-${APP_NAME}-fpm.ini"
fi

## php-custom (specific) for php-cli
if [ -f "${PROJECT_DIR}config/custom/php-custom-cli.ini" ] && [ ! -f "/etc/php/${PHP_VER}/cli/conf.d/95-${APP_NAME}-cli.ini" ]; then
  printTitle "📜 Linking php-custom-cli..."
  ln -s "${PROJECT_DIR}config/custom/php-custom-cli.ini" "/etc/php/${PHP_VER}/cli/conf.d/95-${APP_NAME}-cli.ini"
fi

printTitle "🔃 Restarting PHP..."
/usr/sbin/php-fpm${PHP_VER} -t && service php${PHP_VER}-fpm restart
echo "/etc/php/${PHP_VER}/fpm/conf.d/"
ls -la "/etc/php/${PHP_VER}/fpm/conf.d/" | grep -v '10-\|15-\|20-'
echo ""
echo "/etc/php/${PHP_VER}/cli/conf.d/"
ls -la "/etc/php/${PHP_VER}/cli/conf.d/" | grep -v '10-\|15-\|20-'


## mysql-custom
if [ -f "${PROJECT_DIR}config/custom/mysql-custom.conf" ] && [ -d "/etc/mysql/mysql.conf.d/" ]; then

  # https://serverfault.com/questions/439378/mysql-not-reading-symlinks-for-options-files-my-cnf
  printTitle "📜 Copying mysql-custom..."
  cp "${PROJECT_DIR}config/custom/mysql-custom.conf" "/etc/mysql/mysql.conf.d/95-${APP_NAME}.cnf"

  printTitle "🔃 Restarting MySQL..."
  service mysql restart
  echo "/etc/mysql/mysql.conf.d/"
  ls -la "/etc/mysql/mysql.conf.d/"
fi


## logrotate
if [ -f "${PROJECT_DIR}config/custom/logrotate.conf" ]; then
  printTitle "📄 Deploying custom logrotate config..."
  # error: Ignoring xxx.conf because the file owner is wrong (should be root or user with uid 0).
  rm -f "/etc/logrotate.d/${APP_NAME}.conf"
  cp "${PROJECT_DIR}config/custom/logrotate.conf" "/etc/logrotate.d/${APP_NAME}.conf"
  chown root:root "/etc/logrotate.d/${APP_NAME}.conf"
  chmod u=rw,go= "/etc/logrotate.d/${APP_NAME}.conf"
fi

printTitle "🔃️ Restarting logrotate..."
echo "/etc/logrotate.d"
ls -la "/etc/logrotate.d"
service logrotate restart


## nginx server{}
if [ -d "/etc/nginx/sites-enabled" ]; then
  NGINX_ETC_CONFD_FULLPATH="/etc/nginx/sites-enabled/"
elif [ -d "/etc/nginx/conf.d" ]; then
  NGINX_ETC_CONFD_FULLPATH="/etc/nginx/conf.d/"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf" ] && [ ! -f "${NGINX_ETC_CONFD_FULLPATH}${APP_NAME}.conf" ]; then
  printTitle "🌎 Linking nginx server {} from ${NGINX_ETC_CONFD_FULLPATH}..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf" "${NGINX_ETC_CONFD_FULLPATH}${APP_NAME}.conf"
fi


## Let's Encrypt Renwal Hook
if [ -d "/etc/letsencrypt/renewal-hooks/deploy" ] && [ ! -f "/etc/letsencrypt/renewal-hooks/deploy/webstackup-nginx-action" ]; then
  printTitle "🔐 Deploy Let's Encrypt post-renewal hook"
  cp "${WEBSTACKUP_SCRIPT_DIR}nginx/lets-encrypt-renewal-hook" "/etc/letsencrypt/renewal-hooks/deploy/webstackup-nginx-action"
fi

if [ -f "/etc/letsencrypt/renewal-hooks/deploy/webstackup-nginx-action" ] && [ -s "/etc/letsencrypt/renewal-hooks/deploy/webstackup-nginx-action" ] ; then
  printTitle "🔐 Renewing Let's Encrypt..."
  certbot renew --force-renewal
fi


printTitle "🔃 Conditional nginx restart..."
echo "/etc/nginx/conf.d"
ls -la "/etc/nginx/conf.d"
nginx -t && service nginx restart

## ElasticSearch
if systemctl --all --type service | grep -q "elasticsearch"; then
  printTitle "🔃 Restarting ElasticSearch (background)..."
  service elasticsearch restart &
fi

## autodeploy
if [ "$APP_ENV" == "staging" ] && [ ! -f "${WEBROOT_DIR}autodeploy-async.php" ]; then
  printTitle "🧙‍♂️ Linking autodeploy..."
  ln -s "${WEBSTACKUP_SCRIPT_DIR}php/autodeploy-async.php" "${WEBROOT_DIR}"
fi

## cache-clear
if [ -f "${SCRIPT_DIR}cache-clear.sh" ]; then
  bash "${SCRIPT_DIR}cache-clear.sh"
fi

## migrations
if [ -f "${SCRIPT_DIR}migrate.sh" ]; then
  bash "${SCRIPT_DIR}migrate.sh"
fi

## user account
if [ ! -z "${USERS_TEMPLATE_PATH}" ]; then
  bash "${WEBSTACKUP_SCRIPT_DIR}account/create_and_copy_template.sh" "$USERS_TEMPLATE_PATH"
fi

if [ "$APP_ENV" == "staging" ] && [ ! -z "${USERS_TEMPLATE_PATH_STAGING}" ]; then
  bash "${WEBSTACKUP_SCRIPT_DIR}account/create_and_copy_template.sh" "$USERS_TEMPLATE_PATH_STAGING"
fi

## zzmysqldump
if [ -f "${PROJECT_DIR}config/custom/zzmysqldump.conf" ] && [ ! -f "/etc/turbolab.it/zzmysqldump.conf" ]; then
  printTitle "🗃️ Linking custom zzmysqldump.conf..."
  ln -s "${PROJECT_DIR}config/custom/zzmysqldump.conf" "/etc/turbolab.it/zzmysqldump.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump-deploy.conf" ] && [ ! -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-deploy.conf" ]; then

  printTitle "🗃️ Linking custom zzmysqldump-deploy.conf (from ${APP_ENV})..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump-deploy.conf" "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-deploy.conf"
  
elif [ -f "${PROJECT_DIR}config/custom/zzmysqldump-deploy.conf" ] && [ ! -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-deploy.conf" ]; then

  printTitle "🗃️ Linking custom zzmysqldump-deploy.conf..."
  ln -s "${PROJECT_DIR}config/custom/zzmysqldump-deploy.conf" "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-deploy.conf"
fi

if [ -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-deploy.conf" ]; then
  zzmysqldump ${APP_NAME}-deploy
  
elif [ -f "/etc/turbolab.it/zzmysqldump.conf" ]; then
  zzmysqldump
fi


## zzfirewall
if [ -f "${PROJECT_DIR}config/custom/zzfirewall-whitelist.conf" ] && [ ! -f "/etc/turbolab.it/zzfirewall-whitelist-${APP_NAME}.conf" ]; then
  printTitle "🔥🧱 Linking zzfirewall-whitelist..."
  ln -s "${PROJECT_DIR}config/custom/zzfirewall-whitelist.conf" "/etc/turbolab.it/zzfirewall-whitelist-${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall-whitelist.conf" ] && [ ! -f "/etc/turbolab.it/zzfirewall-whitelist-${APP_NAME}_${APP_ENV}.conf" ]; then
  printTitle "🔥🧱 Linking ${APP_ENV} zzfirewall-whitelist..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall-whitelist.conf" "/etc/turbolab.it/zzfirewall-whitelist-${APP_NAME}_${APP_ENV}.conf"
fi
