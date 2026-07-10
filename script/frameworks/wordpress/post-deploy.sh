fxTitle "Include Webstackup WordPress defaults in functions.php..."
WSU_WP_INSTANCE_FUNCTIONS_PATH="${WEBROOT_DIR}wp-content/themes/${APP_NAME}/functions.php"
WSU_WP_FUNCTIONS_EXTRAS_PATH="/usr/local/turbolab.it/webstackup/script/php-pages/wordpress/functions-extras.php"

if [ "$WSU_WP_FUNCTIONS_DONT_INCLUDE_EXTRAS" != 1 ] && ! grep -q "$WSU_WP_FUNCTIONS_EXTRAS_PATH" "$WSU_WP_INSTANCE_FUNCTIONS_PATH"; then

  WSU_WP_FUNCTIONS_EXTRAS_CODE="
/** 🔥 WordPress extras for functions.php by WEBSTACKUP **/
// https://github.com/TurboLabIt/webstackup/tree/master/script/php-pages/wordpress/functions-extras.php
// 🎗️ make sure to commit this addition to the Git repository
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
