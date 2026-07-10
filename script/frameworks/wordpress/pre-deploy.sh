fxTitle "Disable Installatron..."
if [ "$WSU_WP_ALLOW_INSTALLATRON" == 1 ]; then

  fxInfo "Installatron IS ALLOWED, skipping 🦘"

elif [ ! -f "${WEBROOT_DIR}wp-content/mu-plugins/automation-by-installatron.php" ]; then

  fxInfo "Skipped (Installatron not found) 🦘"

else

  rm -f "${PROJECT_DIR}backup/automation-by-installatron.php"
  sudo -u $EXPECTED_USER -H mv "${WEBROOT_DIR}wp-content/mu-plugins/automation-by-installatron.php" "${PROJECT_DIR}backup/"
  fxOK "OK, Installatron mu-plugin was found and moved to backup"
fi


fxTitle "Include Webstackup WordPress defaults in wp-config.php..."
WSU_WP_INSTANCE_WPCONFIG_PATH="${WEBROOT_DIR}wp-config.php"
WSU_WP_CONFIG_EXTRAS_PATH="/usr/local/turbolab.it/webstackup/script/php-pages/wordpress/wp-config-extras.php"
WSU_WP_ANCHOR_REGEX="\/\* That's all, stop editing"

if [ "$WSU_WP_WPCONFIG_DONT_INCLUDE_EXTRAS" != 1 ] && ! grep -q "$WSU_WP_ANCHOR_REGEX" "$WSU_WP_INSTANCE_WPCONFIG_PATH"; then
  fxCatastrophicError "Cannot find anchor string ##/* That's all, stop editing! Happy publishing. */## in ##$WSU_WP_INSTANCE_WPCONFIG_PATH##!"
fi

if [ "$WSU_WP_WPCONFIG_DONT_INCLUDE_EXTRAS" != 1 ] && ! grep -q "$WSU_WP_CONFIG_EXTRAS_PATH" "$WSU_WP_INSTANCE_WPCONFIG_PATH"; then

  WSU_WP_CONFIG_EXTRAS_CODE="
/** 🔥 WordPress extras by WEBSTACKUP **/
// https://github.com/TurboLabIt/webstackup/tree/master/script/php-pages/wordpress/wp-config-extras.php
require_once '$WSU_WP_CONFIG_EXTRAS_PATH';
"

  WSU_WP_CONFIG_EXTRAS_CODE_TEMP_FILE_PATH=/tmp/wp-config-extras-require$(date +%Y%m%d_%H%M%S).txt
  echo "$WSU_WP_CONFIG_EXTRAS_CODE" > "${WSU_WP_CONFIG_EXTRAS_CODE_TEMP_FILE_PATH}"

  sed -i "/$WSU_WP_ANCHOR_REGEX/{h;s|.*|cat ${WSU_WP_CONFIG_EXTRAS_CODE_TEMP_FILE_PATH}|e;G;}" "$WSU_WP_INSTANCE_WPCONFIG_PATH"
  
  rm "${WSU_WP_CONFIG_EXTRAS_CODE_TEMP_FILE_PATH}"

  fxOK "Webstackup configuration injected 💉"

elif [ "$WSU_WP_WPCONFIG_DONT_INCLUDE_EXTRAS" == 1 ]; then

  fxInfo "Skipped (disabled in config) 🦘"

else

  fxInfo "Skipped (config already injected) 🦘"
fi


fxTitle "Include Webstackup WordPress defaults in functions.php..."
WSU_WP_INSTANCE_FUNCTIONS_PATH="${WEBROOT_DIR}wp-content/themes/${APP_NAME}/functions.php"
WSU_WP_FUNCTIONS_EXTRAS_PATH="/usr/local/turbolab.it/webstackup/script/php-pages/wordpress/functions-extras.php"

if [ "$WSU_WP_FUNCTIONS_DONT_INCLUDE_EXTRAS" != 1 ] && ! grep -q "$WSU_WP_FUNCTIONS_EXTRAS_PATH" "$WSU_WP_INSTANCE_FUNCTIONS_PATH"; then

  WSU_WP_FUNCTIONS_EXTRAS_CODE="
/** 🔥 WordPress extras for functions.php by WEBSTACKUP **/
// https://github.com/TurboLabIt/webstackup/tree/master/script/php-pages/wordpress/functions-extras.php
require_once '/usr/local/turbolab.it/webstackup/script/php-pages/wordpress/functions-extras.php';"

  WSU_WP_FUNCTIONS_EXTRAS_CODE_TEMP_FILE_PATH=/tmp/wp-functions-extras-require$(date +%Y%m%d_%H%M%S).txt
  echo "$WSU_WP_FUNCTIONS_EXTRAS_CODE" > "${WSU_WP_FUNCTIONS_EXTRAS_CODE_TEMP_FILE_PATH}"

  sed -i -e '/<?php/ {
      r '"${WSU_WP_FUNCTIONS_EXTRAS_CODE_TEMP_FILE_PATH}"'
      :a
      n
      ba
  }' "${WSU_WP_INSTANCE_FUNCTIONS_PATH}"

  rm "${WSU_WP_FUNCTIONS_EXTRAS_CODE_TEMP_FILE_PATH}"

  fxOK "Webstackup functions-extras.php injected 💉"

elif [ "$WSU_WP_FUNCTIONS_DONT_INCLUDE_EXTRAS" == 1 ]; then

  fxInfo "Skipped (disabled in config) 🦘"

else

  fxInfo "Skipped (functions-extras.php already injected) 🦘"
fi


if [ ! -f /usr/local/bin/cachetool ]; then
  fxTitle "Installing cachetool..."
  sudo curl -Lo /usr/local/bin/cachetool https://github.com/gordalina/cachetool/releases/latest/download/cachetool.phar
  sudo chmod u=rwx,go=rx /usr/local/bin/cachetool
fi


fxTitle "Preparing wp-content/mu-plugins/..."
sudo -u $EXPECTED_USER -H mkdir -p "${WEBROOT_DIR}wp-content/mu-plugins"


fxTitle "mu-plugin: allow WordPress to auto-update even with .git..."
if [ "$WSU_WP_GIT_BLOCKS_AUTOUPDATE" != 1 ]; then

  sudo -u $EXPECTED_USER -H rm -f "${WEBROOT_DIR}wp-content/mu-plugins/disable-git-check.php"
  sudo -u $EXPECTED_USER -H ln -s "/usr/local/turbolab.it/webstackup/script/php-pages/wordpress/disable-git-check.php" "${WEBROOT_DIR}wp-content/mu-plugins/disable-git-check.php"
  fxOK "OK, mu-plugin activated"

else

  fxInfo "Skipped (disabled in config) 🦘"
fi


fxTitle "mu-plugin: opcache_reset() on upgrade..."
sudo -u $EXPECTED_USER -H rm -f "${WEBROOT_DIR}wp-content/mu-plugins/opcache-reset-on-upgrade.php"
sudo -u $EXPECTED_USER -H ln -s "/usr/local/turbolab.it/webstackup/script/php-pages/wordpress/opcache-reset-on-upgrade.php" "${WEBROOT_DIR}wp-content/mu-plugins/opcache-reset-on-upgrade.php"
fxOK "OK, mu-plugin activated"


fxTitle "Deploying opcache revalidation config for PHP-FPM..."
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/opcache-revalidate-timestamp.ini" \
  "/etc/php/${PHP_VER}/fpm/conf.d/35-webstackup-opcache-revalidate-timestamp.ini"
