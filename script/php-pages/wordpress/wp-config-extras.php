<?php
// allow to install plugins/themes via admin
define('FS_METHOD', 'direct');

// auto-update: security and minor only
define('AUTOMATIC_UPDATER_DISABLED', false);
define('WP_AUTO_UPDATE_CORE', 'minor');

// Disable wp-cron.php (use config/custom/cron + script/cron.sh instead)
define('DISABLE_WP_CRON', true);

// Disable revisions - add `define('WP_POST_REVISIONS', <true|7>);` to wp-config to keep the revisions
if( !defined( 'WP_POST_REVISIONS' ) ) {
    define('WP_POST_REVISIONS', false);
}
