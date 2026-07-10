<?php
/*
  Plugin Name: Reset OPcache after WordPress self-updates
  Description: Resets OPcache after every core/plugin/theme/translation upgrade, so php-fpm can't keep serving stale code (opcache.validate_timestamps=0).
*/
add_action('upgrader_process_complete', 'wsu_opcache_reset_after_upgrade', 9999);

function wsu_opcache_reset_after_upgrade() : void
{
    // resets the OPcache of the SAPI running the upgrade (php-fpm when updating via wp-admin)
    if( function_exists('opcache_reset') ) {
        @opcache_reset();
    }

    // on webstackup, auto-updates run via WP-CLI (DISABLE_WP_CRON + scripts/cron.sh): the reset
    // above can't touch php-fpm's OPcache => reset it through the FPM socket via cachetool.
    // exec() is FPM-only-disabled (no-exec.ini), so this branch is CLI-only by construction
    if( PHP_SAPI != 'cli' || !function_exists('exec') ) {
        return;
    }

    $fpmSocket = sprintf('/run/php/php%d.%d-fpm.sock', PHP_MAJOR_VERSION, PHP_MINOR_VERSION);
    $cachetool = '/usr/local/bin/cachetool';

    if( !file_exists($fpmSocket) || !is_file($cachetool) ) {
        error_log("WSU opcache-reset-on-upgrade: php-fpm OPcache NOT reset (##{$fpmSocket}## or ##{$cachetool}## not found)");
        return;
    }

    $command =
        escapeshellarg(PHP_BINARY) . ' ' . escapeshellarg($cachetool) .
        ' opcache:reset --fcgi=' . escapeshellarg($fpmSocket) . ' 2>&1';

    exec($command, $output, $exitCode);

    if( $exitCode !== 0 ) {
        error_log('WSU opcache-reset-on-upgrade: cachetool failed: ' . implode(' | ', $output));
    }
}
