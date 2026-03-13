### MANAGED FILES ###
#####################

# ${PROJECT_DIR}composer.json
# ${WEBROOT_DIR}composer.json

# ${SCRIPT_DIR}deploy.sh
# ${SCRIPT_DIR}cache-clear.sh
# ${SCRIPT_DIR}test-runner.sh
# ${SCRIPT_DIR}maintenance.sh

# user accounts - https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/ssh-accounts/readme.md
# USERS_TEMPLATE_PATH=/my-path/accounts
# USERS_TEMPLATE_PATH_STAGING=/my-path/accounts-staging
# ${PROJECT_DIR}config/custom/ssh-accounts

# ${SCRIPT_DIR}zzcd_bookmarks.sh

# ${SCRIPT_DIR}bashrc.sh

# ${PROJECT_DIR}config/custom/cron
# ${PROJECT_DIR}config/custom/${APP_ENV}/cron

# ${PROJECT_DIR}config/custom/php-custom.ini
# ${PROJECT_DIR}config/custom/php-custom-fpm.ini
# ${PROJECT_DIR}config/custom/php-custom-cli.ini
# ${PROJECT_DIR}config/custom/php-fpm.conf

# ${PROJECT_DIR}config/custom/mysql-custom.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/mysql-custom.conf

# ${PROJECT_DIR}config/custom/logrotate.conf

# ${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf

# AUTODEPLOY https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/readme.md#how-to-autodeploy

# ${PROJECT_DIR}config/custom/zzmysqldump.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump.conf

# ${PROJECT_DIR}config/custom/zzfirewall.conf
# ${PROJECT_DIR}config/custom/zzfirewall-whitelist.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall-whitelist.conf

# ${PROJECT_DIR}config/custom/nginx-allow-deny-list.conf
# ${PROJECT_DIR}config/custom/${APP_ENV}/nginx-allow-deny-list.conf

# ${PROJECT_DIR}config/custom/sshd.conf

# ${PROJECT_DIR}config/custom/${APP_ENV}/netplan.yaml

# ${PROJECT_DIR}config/custom/${APP_ENV}/varnish.vcl
# ${PROJECT_DIR}config/custom/varnish.vcl



fxHeader "DEPLOY-COMMON"


if [ "${APP_ENV}" != 'prod' ] && [ "${APP_ENV}" != 'staging' ]; then
  fxCatastrophicError "Common deploy ops can't run in this APP_ENV (##${APP_ENV}##)"
fi

if [ -z "${APP_NAME}" ] || [ -z "${EXPECTED_USER}" ] || [ -z "${PHP_VER}" ] ||  [ -z "${PROJECT_DIR}" ] || [ -z "${SCRIPT_DIR}" ]; then

  fxCatastrophicError "Common deploy ops can't run with these variables undefined:
  
  APP_NAME:       ##${APP_NAME}##
  EXPECTED_USER:  ##${EXPECTED_USER}##
  PHP_VER:        ##${PHP_VER}##
  PROJECT_DIR:    ##${PROJECT_DIR}##
  SCRIPT_DIR:     ##${SCRIPT_DIR}##"
fi


##
fxTitle "#️⃣ Pre-pull hashing"
echo "Hashing the sourcing script ##${0}##"
DEPLOY_SCRIPT_PREPULL_HASH=`md5sum $0 | awk '{ print $1 }'`
echo "Hash: $DEPLOY_SCRIPT_PREPULL_HASH"


fxTitle "Fetching origin..."
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" fetch --depth 1

fxTitle "Resetting to upstream..."
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" reset --hard @{upstream}

fxTitle "🗜️ Pruning..."
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" gc --prune=all

fxTitle "Setting git fileMode: false"
sudo -u ${EXPECTED_USER} -H git -C "${PROJECT_DIR}" config core.fileMode false


fxTitle "#️⃣ Post-pull hashing"
echo "Hashing the sourcing script ##${0}##"
DEPLOY_SCRIPT_POSTPULL_HASH=`md5sum $0 | awk '{ print $1 }'`
echo "Hash: $DEPLOY_SCRIPT_POSTPULL_HASH"

if [ "${DEPLOY_SCRIPT_PREPULL_HASH}" != "${DEPLOY_SCRIPT_POSTPULL_HASH}" ] && [ ! -z "${LOCKFILE}" ]; then
  rm -f "${LOCKFILE}"
fi

if [ "${DEPLOY_SCRIPT_PREPULL_HASH}" != "${DEPLOY_SCRIPT_POSTPULL_HASH}" ]; then
  fxCatastrophicError "The deploy script has been updated by the pull! Please run it again!"
fi


## show PHP the selected PHP version
source "${WEBSTACKUP_SCRIPT_DIR}php/commands.sh"
showPHPVer


## cleanup
fxTitle "🧹 Cleaning up..."
rm -rf /tmp/.symfony
rm -rf /tmp/magento


## composer
if [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${PROJECT_DIR}composer.json" ]; then

  COMPOSER_JSON_FULLPATH=${PROJECT_DIR}composer.json

elif [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${WEBROOT_DIR}composer.json" ]; then

  COMPOSER_JSON_FULLPATH=${WEBROOT_DIR}composer.json
fi

if [ ! -z "${COMPOSER_JSON_FULLPATH}" ]; then

  fxTitle "📦 Removing composer dump-autoload..."
  rm -f "$(dirname ${COMPOSER_JSON_FULLPATH})/vendor/composer/autoload_classmap.php"

  fxTitle "📦 Composer install from ##${COMPOSER_JSON_FULLPATH}##..."
  sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" /usr/bin/php${PHP_VER} /usr/local/bin/composer install --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})" --no-dev --no-interaction
  sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" /usr/bin/php${PHP_VER} /usr/local/bin/composer dump-env ${APP_ENV} --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})" --no-interaction
  
fi

if [ ! -z "${COMPOSER_JSON_FULLPATH}" ] && [ "${COMPOSER_SKIP_DUMP_AUTOLOAD}" != 1 ]; then

  fxTitle "📦 Composer dump-autoload..."
  sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" /usr/bin/php${PHP_VER} /usr/local/bin/composer dump-autoload --classmap-authoritative --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})" --no-dev --no-interaction

fi


fxTitle "Activating zzcommands..."
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
  fxTitle "📂 Linking zzcd config..."
  rm -f "/etc/turbolab.it/zzcd_bookmarks.sh"
  ln -s "${SCRIPT_DIR}zzcd_bookmarks.sh" "/etc/turbolab.it/zzcd_bookmarks.sh"
fi


## removing cron
fxTitle "🧹 Removing ${APP_NAME} cron files..."
sudo rm -f /etc/cron.d/${APP_NAME}

fxTitle "🧹 Removing ${APP_NAME}_${APP_ENV} cron files..."
sudo rm -f /etc/cron.d/${APP_NAME}_${APP_ENV}

fxTitle "📂 Listing /etc/cron.d/..."
ls -l "/etc/cron.d/"


function deployPhpLinker()
{
  local PHP_FILE=$1
  
  if [ ! -f "${PHP_FILE}" ]; then
    return 255
  fi
  
  local LINK_FILE=$2
  fxTitle "📜 ${LINK_FILE}..."
  rm -f "${LINK_FILE}"
  ln -s "${PHP_FILE}" "${LINK_FILE}"
}

deployPhpLinker "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/fpm/conf.d/90-${APP_NAME}.ini"
deployPhpLinker "${PROJECT_DIR}config/custom/php-custom.ini" "/etc/php/${PHP_VER}/cli/conf.d/90-${APP_NAME}.ini"
deployPhpLinker "${PROJECT_DIR}config/custom/php-custom-fpm.ini" "/etc/php/${PHP_VER}/fpm/conf.d/95-${APP_NAME}-fpm.ini"
deployPhpLinker "${PROJECT_DIR}config/custom/php-custom-cli.ini" "/etc/php/${PHP_VER}/cli/conf.d/95-${APP_NAME}-cli.ini"

fxTitle "📂 Listing /etc/php/${PHP_VER}/fpm/conf.d/..."
ls -l "/etc/php/${PHP_VER}/fpm/conf.d/" | grep -v '10-\|15-\|20-'

fxTitle "📂 Listing /etc/php/${PHP_VER}/cli/conf.d/..."
ls -l "/etc/php/${PHP_VER}/cli/conf.d/" | grep -v '10-\|15-\|20-'


if [ -f "${PROJECT_DIR}config/custom/php-fpm.conf" ] && [ ! -f "/etc/php/${PHP_VER}/fpm/pool.d/zzz_${APP_NAME}.conf" ]; then
  fxTitle "🔨 Linking PHP FPM custom config..."
  ln -s "${PROJECT_DIR}config/custom/php-fpm.conf" "/etc/php/${PHP_VER}/fpm/pool.d/zzz_${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/php-fpm.conf" ]  && [ ! -f "/etc/php/${PHP_VER}/fpm/pool.d/zzz-${APP_NAME}_${APP_ENV}.conf" ]; then

  fxTitle "🔨 Linking PHP FPM ${APP_ENV} php-fpm..."
  ln -s  "${PROJECT_DIR}config/custom/${APP_ENV}/php-fpm.conf" "/etc/php/${PHP_VER}/fpm/pool.d/zzz-${APP_NAME}_${APP_ENV}.conf"
fi


fxTitle "🔃️ Restarting PHP-FPM..."
/usr/sbin/php-fpm${PHP_VER} -t && service php${PHP_VER}-fpm restart


## mysql-custom
if [ -f "${PROJECT_DIR}config/custom/mysql-custom.conf" ] && [ -d "/etc/mysql/mysql.conf.d/" ]; then

  # https://serverfault.com/questions/439378/mysql-not-reading-symlinks-for-options-files-my-cnf
  fxTitle "📜 Copying mysql-custom..."
  cp "${PROJECT_DIR}config/custom/mysql-custom.conf" "/etc/mysql/mysql.conf.d/95-${APP_NAME}.cnf"
  chmod u=rw,go=r "/etc/mysql/mysql.conf.d/95-${APP_NAME}.cnf"

  fxTitle "📂 Listing /etc/mysql/mysql.conf.d/..."
  ls -l "/etc/mysql/mysql.conf.d/"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/mysql-custom.conf" ] && [ -d "/etc/mysql/mysql.conf.d/" ]; then

  fxTitle "📜 Copying ${APP_ENV} mysql-custom..."
  cp "${PROJECT_DIR}config/custom/${APP_ENV}/mysql-custom.conf" "/etc/mysql/mysql.conf.d/96-${APP_NAME}_${APP_ENV}.cnf"
  chmod u=rw,go=r "/etc/mysql/mysql.conf.d/96-${APP_NAME}_${APP_ENV}.cnf"

  fxTitle "📂 Listing /etc/mysql/mysql.conf.d/..."
  ls -l "/etc/mysql/mysql.conf.d/"
fi


## logrotate
if [ -f "${PROJECT_DIR}config/custom/logrotate.conf" ]; then

  fxTitle "📄 Deploying custom logrotate config..."
  # error: Ignoring xxx.conf because the file owner is wrong (should be root or user with uid 0).
  rm -f "/etc/logrotate.d/${APP_NAME}.conf"
  cp "${PROJECT_DIR}config/custom/logrotate.conf" "/etc/logrotate.d/${APP_NAME}.conf"
  chown root:root "/etc/logrotate.d/${APP_NAME}.conf"
  chmod u=rw,go= "/etc/logrotate.d/${APP_NAME}.conf"

  fxTitle "📂 Listing /etc/logrotate.d/..."
  ls -l "/etc/logrotate.d"
fi


## nginx server{}
if [ -d "/etc/nginx/sites-enabled" ]; then
  NGINX_ETC_CONFD_FULLPATH="/etc/nginx/sites-enabled/"
elif [ -d "/etc/nginx/conf.d" ]; then
  NGINX_ETC_CONFD_FULLPATH="/etc/nginx/conf.d/"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf" ] && [ ! -f "${NGINX_ETC_CONFD_FULLPATH}${APP_NAME}.conf" ]; then
  fxTitle "🌎 Linking nginx server {} from ${NGINX_ETC_CONFD_FULLPATH}..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/nginx.conf" "${NGINX_ETC_CONFD_FULLPATH}${APP_NAME}.conf"
fi


## Let's Encrypt renewal
if [ -d /etc/letsencrypt ] && [ ! -f /etc/letsencrypt/renewal-hooks/deploy/webstackup-certificate-renewal-action.sh ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}https/letsencrypt-create-hooks.sh
fi

if [ "${LETS_ENCRYPT_SKIP_RENEW}" = 0 ] && [ -d /etc/letsencrypt/ ]; then
  fxTitle "🔐 Renewing Let's Encrypt..."
  certbot renew --dry-run --no-random-sleep-on-renew && certbot renew --no-random-sleep-on-renew
fi


fxTitle "📂 Listing /etc/nginx/conf.d/..."
ls -l /etc/nginx/conf.d


## ElasticSearch
systemctl --all --type service | grep -q "elasticsearch"
if [ "$?" = 0 ] && [ "${DEPLOY_ELASTICSEARCH_RESTART}" != 0 ]; then
  fxTitle "🔃 Restarting ElasticSearch (background)..."
  service elasticsearch restart &
fi


## async-runner-request
if [ "$APP_ENV" = "staging" ] && [ ! -f "${WEBROOT_DIR}async-runner-request.php" ]; then
  fxTitle "🏃‍♂️ Linking async-runner-request.php..."
  ln -s "${WEBSTACKUP_SCRIPT_DIR}php-pages/async-runner-request.php" "${WEBROOT_DIR}"
fi

## autodeploy https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/readme.md#how-to-autodeploy
if [ "$APP_ENV" = "staging" ] && [ ! -f "${WEBROOT_DIR}autodeploy-async.php" ]; then
  fxTitle "🤖 Linking autodeploy..."
  ln -s "${WEBSTACKUP_SCRIPT_DIR}php-pages/autodeploy-async.php" "${WEBROOT_DIR}"
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

  fxTitle "🛟 Linking custom zzmysqldump ${APP_NAME}..."
  ln -s "${PROJECT_DIR}config/custom/zzmysqldump.conf" "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump.conf" ] && [ ! -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}.conf" ]; then

  fxTitle "🛟 Linking custom zzmysqldump ${APP_NAME} (from ${APP_ENV})..."
  ln -s "${PROJECT_DIR}config/${APP_ENV}/custom/zzmysqldump.conf" "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/zzmysqldump.conf" ] && [ ! -f "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-${APP_ENV}.conf" ]; then

  fxTitle "🛟 Linking custom zzmysqldump ${APP_NAME}-${APP_ENV}..."
  ln -s "${PROJECT_DIR}config/${APP_ENV}/custom/zzmysqldump.conf" "/etc/turbolab.it/zzmysqldump.profile.${APP_NAME}-${APP_ENV}.conf"
fi


## zzfirewall
if [ -f "${PROJECT_DIR}config/custom/zzfirewall.conf" ]; then

  fxTitle "🔥🧱 Linking zzfirewall..."
  rm -f "/etc/turbolab.it/zzfirewall.conf"
  ln -s "${PROJECT_DIR}config/custom/zzfirewall.conf" "/etc/turbolab.it/zzfirewall.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall.conf" ]; then

  fxTitle "🔥🧱 Linking ${APP_ENV} zzfirewall..."
  rm -f "/etc/turbolab.it/zzfirewall.conf"
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall.conf" "/etc/turbolab.it/zzfirewall.conf"
fi


if [ -f "${PROJECT_DIR}config/custom/zzfirewall-whitelist.conf" ] && [ ! -f "/etc/turbolab.it/zzfirewall-whitelist-${APP_NAME}.conf" ]; then

  fxTitle "🔥🧱 Linking zzfirewall-whitelist..."
  ln -s "${PROJECT_DIR}config/custom/zzfirewall-whitelist.conf" "/etc/turbolab.it/zzfirewall-whitelist-${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall-whitelist.conf" ] && [ ! -f "/etc/turbolab.it/zzfirewall-whitelist-${APP_NAME}_${APP_ENV}.conf" ]; then

  fxTitle "🔥🧱 Linking ${APP_ENV} zzfirewall-whitelist..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/zzfirewall-whitelist.conf" "/etc/turbolab.it/zzfirewall-whitelist-${APP_NAME}_${APP_ENV}.conf"
fi


## phpbb-upgrader
if [ -f "${PROJECT_DIR}config/custom/phpbb-upgrader.conf" ] && [ ! -f "/etc/turbolab.it/phpbb-upgrader-${APP_NAME}.conf" ]; then
  fxTitle "🤼 Linking phpBB Upgrader ${APP_NAME} config..."
  ln -s "${PROJECT_DIR}config/custom/phpbb-upgrader.conf" "/etc/turbolab.it/phpbb-upgrader-${APP_NAME}.conf"
fi


## nginx-allow-deny-list
if [ -f "${PROJECT_DIR}config/custom/nginx-allow-deny-list.conf" ] && [ ! -f "/etc/turbolab.it/webstackup-nginx-allow-deny-list-${APP_NAME}.conf" ]; then
  fxTitle "🚪 Linking nginx-allow-deny-list..."
  ln -s "${PROJECT_DIR}config/custom/nginx-allow-deny-list.conf" "/etc/turbolab.it/webstackup-nginx-allow-deny-list-${APP_NAME}.conf"
fi

if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/nginx-allow-deny-list.conf" ] && [ ! -f "/etc/turbolab.it/webstackup-nginx-allow-deny-list-${APP_NAME}_${APP_ENV}.conf" ]; then
  fxTitle "🚪 Linking ${APP_ENV} nginx-allow-deny-list..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/nginx-allow-deny-list.conf" "/etc/turbolab.it/webstackup-nginx-allow-deny-list-${APP_NAME}_${APP_ENV}.conf"
fi


## sshd config
if [ -f "${PROJECT_DIR}config/custom/sshd.conf" ] && [ ! -f "/etc/ssh/sshd_config.d/${APP_NAME}.conf" ]; then

  fxTitle "🚪 Linking sshd..."
  ln -s "${PROJECT_DIR}config/custom/sshd.conf" "/etc/ssh/sshd_config.d/${APP_NAME}.conf"
  
  fxTitle "📂 Listing /etc/ssh/sshd_config.d/..."
  ls -l "/etc/ssh/sshd_config.d/"
fi


## netplan network interface config
if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/netplan.yaml" ] && [ ! -f "/etc/netplan/${APP_NAME}.yaml" ]; then

  fxTitle "🛜 Linking netplan.yaml from /etc/netplan/..."
  ln -s "${PROJECT_DIR}config/custom/${APP_ENV}/netplan.yaml" "/etc/netplan/${APP_NAME}.yaml"

  fxTitle "🛜 Applying netplan config..."
  netplan apply
fi


## varnish
if [ -d "/etc/varnish" ] && [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/varnish.vcl" ]; then

  fxTitle "🪣 Deploying custom Varnish config for the ${APP_ENV} env..."
  rm -f "/etc/varnish/default.vcl"
  cp "${PROJECT_DIR}config/custom/${APP_ENV}/varnish.vcl" "/etc/varnish/default.vcl"

elif [ -d "/etc/varnish" ] && [ -f "${PROJECT_DIR}config/custom/varnish.vcl" ]; then

  fxTitle "🪣 Deploying custom Varnish config..."
  rm -f "/etc/varnish/default.vcl"
  cp "${PROJECT_DIR}config/custom/varnish.vcl" "/etc/varnish/default.vcl"
fi


WSU_VARNISH_SERVICE_OVERRIDE_PATH=/etc/systemd/system/varnish.service.d/varnish.service
if [ -d "/etc/varnish" ] && [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/varnish.service" ]; then

  fxTitle "🪣 Deploying custom Varnish service unit file for the ${APP_ENV} env..."
  mkdir -p "${WSU_VARNISH_SERVICE_OVERRIDE_PATH%/*}"
  rm -f "${WSU_VARNISH_SERVICE_OVERRIDE_PATH}"
  cp "${PROJECT_DIR}config/custom/${APP_ENV}/varnish.service" "${WSU_VARNISH_SERVICE_OVERRIDE_PATH}"

elif [ -d "/etc/varnish" ] && [ -f "${PROJECT_DIR}config/custom/varnish.service" ]; then

  fxTitle "🪣 Deploying custom Varnish service unit file..."
  mkdir -p "${WSU_VARNISH_SERVICE_OVERRIDE_PATH%/*}"
  rm -f "${WSU_VARNISH_SERVICE_OVERRIDE_PATH}"
  cp "${PROJECT_DIR}config/custom/varnish.service" "${WSU_VARNISH_SERVICE_OVERRIDE_PATH}"
fi


## services restart
systemctl daemon-reload

fxTitle "🔃 Conditional nginx stop..."
nginx -t && service nginx stop

## MySQL
systemctl --all --type service | grep -q "mysql"
if [ "$?" = 0 ] && [ "${DEPLOY_MYSQL_RESTART}" != 0 ]; then
  fxTitle "🔃 Restarting MySQL..."
  service mysql restart
fi

## Varnish
systemctl --all --type service | grep -q "varnish"
if [ "$?" = 0 ] && [ "${DEPLOY_VARNISH_RESTART}" != 0 ]; then
  fxTitle "🔃 Restarting Varnish..."
  service varnish restart
fi

fxTitle "🔃️ Restarting logrotate..."
service logrotate restart

fxTitle "🔃 Conditional nginx restart..."
nginx -t && service nginx restart

fxTitle "🔃️ Restarting sshd..."
service ssh restart


fxTitle "Patching $(logname) .bashrc..."
LOGGED_USER_BASHRC=$(fxGetUserHomePath $(logname)).bashrc
fxInfo "###${LOGGED_USER_BASHRC}###"

if [ ! -f "${LOGGED_USER_BASHRC}" ]; then
  touch "${LOGGED_USER_BASHRC}"
fi

if ! grep -q "scripts/bashrc.sh" "${LOGGED_USER_BASHRC}"; then

  echo "" >> "${LOGGED_USER_BASHRC}"
  echo "## Webstackup" >> "${LOGGED_USER_BASHRC}"
  echo "source ${SCRIPT_DIR}bashrc.sh" >> "${LOGGED_USER_BASHRC}"
  fxOK "${LOGGED_USER_BASHRC} has been patched"
fi


## cache-clear
if [ -f "${SCRIPT_DIR}cache-clear.sh" ]; then
  bash "${SCRIPT_DIR}cache-clear.sh"
fi


## cron
if [ "${DEPLOY_COPY_CRON}" != 0 ]; then

  if [ -f "${PROJECT_DIR}config/custom/cron" ]; then
    fxTitle "⏲️ Copying shared cron file..."
    cp "${PROJECT_DIR}config/custom/cron" "/etc/cron.d/${APP_NAME//./_}"
  fi

  if [ -f "${PROJECT_DIR}config/custom/${APP_ENV}/cron" ]; then
    fxTitle "⏲️ Copying ${APP_ENV} cron file..."
    cp "${PROJECT_DIR}config/custom/${APP_ENV}/cron" "/etc/cron.d/${APP_NAME//./_}_${APP_ENV}"
  fi

  fxTitle "🔃️ Reloading cron..."
  ## cron shouldn't be restarted, or you may get:
  # `cron.service: Found left-over process 2093062 (cron) in control group while starting unit. Ignoring.`
  service cron reload

else

  fxWarning "DEPLOY_COPY_CRON is set to zero, skipping 🦘"
fi

fxTitle "📂 Listing /etc/cron.d/..."
ls -l "/etc/cron.d/"


## delete test files
fxTitle "👮 Deleting test.php, phpinfo.php and similar..."
rm -f "${WEBROOT_DIR}test.php" "${WEBROOT_DIR}phpinfo.php"
