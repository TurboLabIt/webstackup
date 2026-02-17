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

// the default debug filepath is public and web-facing (/wp-content/debug.log) => changing it to a private path
// note: you must switch the logging on with `define('WP_DEBUG', false);` in wp-config
define( 'WP_DEBUG_LOG', __DIR__ . '/../var/log/wordpress-debug.log' );
