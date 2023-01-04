### MANAGED FILES ###
#####################

# ${PROJECT_DIR}composer.json
# ${WEBROOT_DIR}composer.json

# ${SCRIPT_DIR}deploy.sh
# ${SCRIPT_DIR}cache-clear.sh
# ${SCRIPT_DIR}test-runner.sh
# ${SCRIPT_DIR}migrate.sh
# ${SCRIPT_DIR}maintenance.sh

# user accounts - https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/ssh-accounts/readme.md
# USERS_TEMPLATE_PATH=/my-path/accounts
# USERS_TEMPLATE_PATH_STAGING=/my-path/accounts-staging
# ${PROJECT_DIR}config/custom/ssh-accounts

# ${SCRIPT_DIR}zzcd_bookmarks.sh

# ${PROJECT_DIR}config/custom/cron
# ${PROJECT_DIR}config/custom/${APP_ENV}/cron

# ${PROJECT_DIR}config/custom/php-custom.ini
# ${PROJECT_DIR}config/custom/php-custom-fpm.ini
# ${PROJECT_DIR}config/custom/php-custom-cli.ini

# ${PROJECT_DIR}config/custom/mysql-custom.conf

# ${PROJECT_DIR}config/custom/logrotate.conf

# ${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf

# AUTODEPLOY https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/readme.md#how-to-autodeploy

# ${PROJECT_DIR}config/custom/zzmysqldump.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump.conf

# ${PROJECT_DIR}config/custom/zzfirewall-whitelist.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall-whitelist.conf

# ${PROJECT_DIR}config/custom/nginx-allow-deny-list.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/nginx-allow-deny-list.conf


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
sudo -u $(logname) -H git config --global --add safe.directory "${PROJECT_DIR}"
sudo -u ${EXPECTED_USER} -H git config --global --add safe.directory "${PROJECT_DIR}"
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" reset --hard
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" pull
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" gc --aggressive
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" config core.fileMode false

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

## show PHP the selected PHP version
showPHPVer


## cleanup
printTitle "🧹 Cleaning up..."
rm -rf /tmp/.symfony
rm -rf /tmp/magento


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


function deployZzCmdSuffix()
{
  if [ -z "${ZZ_CMD_SUFFIX}" ] || [ "${ZZ_CMD_SUFFIX}" = "0" ]; then
    echo ""
  else
   echo "-${APP_NAME}"
  fi
}


function deployCmdLinker()
{
  local SCRIPT_FILE=$1
  
  if [ ! -f "${SCRIPT_FILE}" ]; then
    return 255
  fi
  
  local LINK_NAME=${2}$(deployZzCmdSuffix)
  
  fxLinkBin "${SCRIPT_FILE}" "${LINK_NAME}"
}

deployCmdLinker "${SCRIPT_DIR}deploy.sh" "zzdeploy"
deployCmdLinker "${SCRIPT_DIR}cache-clear.sh" "zzcache"
deployCmdLinker "${SCRIPT_DIR}maintenance.sh" "zzmaintenance"
deployCmdLinker "${SCRIPT_DIR}test-runner.sh" "zztest"

## zzcd bookmarks
if [ -f "${SCRIPT_DIR}zzcd_bookmarks.sh" ] && [ -z "$(deployZzCmdSuffix)" ]; then
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

printTitle "📂 Listing /etc/cron.d/..."
ls -l "/etc/cron.d/"

printTitle "🔃️ Reloading cron..."
## cron shouldn't be restarted, or you'll get:
# `cron.service: Found left-over process 2093062 (cron) in control group while starting unit. Ignoring.`
service cron reload

function deployPhpLinker()
{
  local PHP_FILE=$1
  
  if [ ! -f "${PHP_FILE}" ]; then
    return 255
  fi
  
  local LINK_FILE=$2
  printTitle "📜 ${LINK_FILE}..."
  rm -f "${LINK_FILE}"
  ln -s "${PHP_FILE}" "${LINK_FILE}"
}

deployPhpLinker "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/fpm/conf.d/90-${APP_NAME}.ini"
deployPhpLinker "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/cli/conf.d/90-${APP_NAME}.ini"
deployPhpLinker "${PROJECT_DIR}config/custom/php-custom-fpm.ini" "/etc/php/${PHP_VER}/fpm/conf.d/95-${APP_NAME}-fpm.ini"
deployPhpLinker "${PROJECT_DIR}config/custom/php-custom-cli.ini" "/etc/php/${PHP_VER}/cli/conf.d/95-${APP_NAME}-cli.ini"

printTitle "📂 Listing /etc/php/${PHP_VER}/fpm/conf.d/..."
ls -l "/etc/php/${PHP_VER}/fpm/conf.d/" | grep -v '10-\|15-\|20-'

printTitle "🔃️ Restarting PHP-FPM..."
/usr/sbin/php-fpm${PHP_VER} -t && service php${PHP_VER}-fpm restart

printTitle "📂 Listing /etc/php/${PHP_VER}/cli/conf.d/..."
ls -l "/etc/php/${PHP_VER}/cli/conf.d/" | grep -v '10-\|15-\|20-'


## mysql-custom
if [ -f "${PROJECT_DIR}config/custom/mysql-custom.conf" ] && [ -d "/etc/mysql/mysql.conf.d/" ]; then

  # https://serverfault.com/questions/439378/mysql-not-reading-symlinks-for-options-files-my-cnf
  printTitle "📜 Copying mysql-custom..."
  cp "${PROJECT_DIR}config/custom/mysql-custom.conf" "/etc/mysql/mysql.conf.d/95-${APP_NAME}.cnf"
  chmod u=rw,go=r "/etc/mysql/mysql.conf.d/95-${APP_NAME}.cnf"
  
  printTitle "🔃️ Restarting MySQL..."
  service mysql restart

  printTitle "📂 Listing /etc/mysql/mysql.conf.d/..."
  ls -l "/etc/mysql/mysql.conf.d/"
fi


## logrotate
if [ -f "${PROJECT_DIR}config/custom/logrotate.conf" ]; then

  printTitle "📄 Deploying custom logrotate config..."
  # error: Ignoring xxx.conf because the file owner is wrong (should be root or user with uid 0).
  rm -f "/etc/logrotate.d/${APP_NAME}.conf"
  cp "${PROJECT_DIR}config/custom/logrotate.conf" "/etc/logrotate.d/${APP_NAME}.conf"
  chown root:root "/etc/logrotate.d/${APP_NAME}.conf"
  chmod u=rw,go= "/etc/logrotate.d/${APP_NAME}.conf"
  
  printTitle "🔃️ Restarting logrotate..."
  service logrotate restart

  printTitle "📂 Listing /etc/logrotate.d/..."
  ls -l "/etc/logrotate.d"
fi


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
nginx -t && service nginx restart

printTitle "📂 Listing /etc/nginx/conf.d/..."
ls -l /etc/nginx/conf.d


## ElasticSearch
systemctl --all --type service | grep -q "elasticsearch"
if [ "$?" = 0 ] && [ "${DEPLOY_ELASTICSEARCH_RESTART}" != 0 ]; then
  printTitle "🔃 Restarting ElasticSearch (background)..."
  service elasticsearch restart &
fi

## async-runner-request
if [ "$APP_ENV" = "staging" ] && [ ! -f "${WEBROOT_DIR}async-runner-request.php" ]; then
  printTitle "🏃‍♂️ Linking async-runner-request.php..."
  ln -s "${WEBSTACKUP_SCRIPT_DIR}php-pages/async-runner-request.php" "${WEBROOT_DIR}"
fi

## autodeploy https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/readme.md#how-to-autodeploy
if [ "$APP_ENV" = "staging" ] && [ ! -f "${WEBROOT_DIR}autodeploy-async.php" ]; then
  printTitle "🤖 Linking autodeploy..."
  ln -s "${WEBSTACKUP_SCRIPT_DIR}php-pages/autodeploy-async.php" "${WEBROOT_DIR}"
fi

## migrations
if [ -f "${SCRIPT_DIR}migrate.sh" ]; then
  bash "${SCRIPT_DIR}migrate.sh"
fi


## user accounts - https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/ssh-accounts/readme.md
if [ ! -z "${USERS_TEMPLATE_PATH}" ]; then
  bash "${WEBSTACKUP_SCRIPT_DIR}account/create_and_copy_template.sh" "$USERS_TEMPLATE_PATH"
fi

if [ "$APP_ENV" == "staging" ] && [ ! -z "${USERS_TEMPLATE_PATH_STAGING}" ]; then
  bash "${WEBSTACKUP_SCRIPT_DIR}account/create_and_copy_template.sh" "$USERS_TEMPLATE_PATH_STAGING"
fi

if [ -d "${PROJECT_DIR}config/custom/ssh-accounts" ] && [ ! -z "$(ls -l ${PROJECT_DIR}config/custom/ssh-accounts | grep '^d')" ]; then
  bash "${WEBSTACKUP_SCRIPT_DIR}account/create_and_copy_template.sh" "${PROJECT_DIR}config/custom/ssh-accounts"
fi


## zzmysqldump
if [ -f "${PROJECT_DIR}config/custom/zzmysqldump.conf" ] && [ ! -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}.conf" ]; then

  printTitle "🛟 Linking custom zzmysqldump ${APP_NAME}..."
  ln -s "${PROJECT_DIR}config/custom/zzmysqldump.conf" "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump.conf" ] && [ ! -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}.conf" ]; then

  printTitle "🛟 Linking custom zzmysqldump ${APP_NAME} (from ${APP_ENV})..."
  ln -s "${PROJECT_DIR}config/${APP_ENV}/custom/zzmysqldump.conf" "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump.conf" ] && [ ! -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-${APP_ENV}.conf" ]; then

  printTitle "🛟 Linking custom zzmysqldump ${APP_NAME}-${APP_ENV}..."
  ln -s "${PROJECT_DIR}config/${APP_ENV}/custom/zzmysqldump.conf" "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-${APP_ENV}.conf"
fi

if [ -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-${APP_ENV}.conf" ]; then

  zzmysqldump ${APP_NAME}-${APP_ENV}
  
elif [ -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}.conf" ]; then

  zzmysqldump ${APP_NAME}
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


## phpbb-upgrader
if [ -f "${PROJECT_DIR}config/custom/phpbb-upgrader.conf" ] && [ ! -f "/etc/turbolab.it/phpbb-upgrader-${APP_NAME}.conf" ]; then
  printTitle "🤼 Linking phpBB Upgrader ${APP_NAME} config..."
  ln -s "${PROJECT_DIR}config/custom/phpbb-upgrader.conf" "/etc/turbolab.it/phpbb-upgrader-${APP_NAME}.conf"
fi


## nginx-allow-deny-list
if [ -f "${PROJECT_DIR}config/custom/nginx-allow-deny-list.conf" ] && [ ! -f "/etc/turbolab.it/nginx-allow-deny-list-${APP_NAME}.conf" ]; then
  printTitle "🚪 Linking nginx-allow-deny-list..."
  ln -s "${PROJECT_DIR}config/custom/nginx-allow-deny-list.conf" "/etc/turbolab.it/nginx-allow-deny-list-${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/nginx-allow-deny-list.conf" ] && [ ! -f "/etc/turbolab.it/nginx-allow-deny-list-${APP_NAME}_${APP_ENV}.conf" ]; then
  printTitle "🚪 Linking ${APP_ENV} nginx-allow-deny-list..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/nginx-allow-deny-list.conf" "/etc/turbolab.it/nginx-allow-deny-list-${APP_NAME}_${APP_ENV}.conf"
fi


## cache-clear
if [ -f "${SCRIPT_DIR}cache-clear.sh" ]; then
  bash "${SCRIPT_DIR}cache-clear.sh"
fi


## delete test files
fxTitle "👮 Deleting test.php, phpinfo.php and similar..."
rm -f "${WEBROOT_DIR}"test.php "${WEBROOT_DIR}"phpinfo.php
