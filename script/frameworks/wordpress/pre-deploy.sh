fxTitle "Include Webstackup WordPress defaults in wp-config.php..."
WSU_WORDPRESS_INSTANCE_WPCONFIG_PATH="${WEBROOT_DIR}wp-config.php"
WSU_WORDPRESS_CONFIG_EXTRAS_PATH="/usr/local/turbolab.it/webstackup/script/php-pages/wordpress/wp-config-extras.php"

if [ "$WSU_WORDPRESS_WPCONFIG_INCLUDE_EXTRAS" != 1 ] && ! grep -q "$WSU_WORDPRESS_CONFIG_EXTRAS_PATH" "$WSU_WORDPRESS_INSTANCE_WPCONFIG_PATH"; then
  
  WSU_WORDPRESS_CONFIG_EXTRAS_CODE="
/** 🔥 WordPress extras by WEBSTACKUP **/
// https://github.com/TurboLabIt/webstackup/tree/master/script/php-pages/wordpress/wp-config-extras.php
require_once '$WSU_WORDPRESS_CONFIG_EXTRAS_PATH';

"

  WSU_WORDPRESS_CONFIG_EXTRAS_CODE_TEMP_FILE_PATH=/tmp/wp-config-extras-require$(date +%Y%m%d_%H%M%S).txt
  echo "$WSU_WORDPRESS_CONFIG_EXTRAS_CODE" > "${WSU_WORDPRESS_CONFIG_EXTRAS_CODE_TEMP_FILE_PATH}"

  sed -i "/\/\* That's all, stop editing/e cat ${WSU_WORDPRESS_CONFIG_EXTRAS_CODE_TEMP_FILE_PATH}" "$WSU_WORDPRESS_INSTANCE_WPCONFIG_PATH"
  rm "${WSU_WORDPRESS_CONFIG_EXTRAS_CODE_TEMP_FILE_PATH}"

  fxOK "Webstackup configuration injected 💉"

elif [ "$WSU_WORDPRESS_WPCONFIG_INCLUDE_EXTRAS" == 1 ]; then

  fxInfo "Skipped (disabled in config) 🦘"

else

  fxInfo "Skipped (config already injected) 🦘"
fi


fxTitle "Allow WordPress to auto-update even with .git..."
if [ "$WSU_WORDPRESS_GIT_BLOCKS_AUTOUPDATE" != 1 ]; then

  sudo -u $EXPECTED_USER -H mkdir -p "${WEBROOT_DIR}wp-content/mu-plugins"
  sudo -u $EXPECTED_USER -H rm -f "${WEBROOT_DIR}wp-content/mu-plugins/disable-git-check.php"
  sudo -u $EXPECTED_USER -H ln -s "/usr/local/turbolab.it/webstackup/script/php-pages/wordpress/disable-git-check.php" "${WEBROOT_DIR}wp-content/mu-plugins/disable-git-check.php"
  fxOK

else

  fxInfo "Skipped (disabled in config) 🦘"
fi

