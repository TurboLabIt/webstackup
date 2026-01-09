<?php
// allow to install plugins/themes via admin
define('FS_METHOD', 'direct');

// auto-update: security and minor only
define('AUTOMATIC_UPDATER_DISABLED', false);
define('WP_AUTO_UPDATE_CORE', 'minor');

// Disable wp-cron.php (use config/custom/cron + script/cron.sh instead)
define('DISABLE_WP_CRON', true);
