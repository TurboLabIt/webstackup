<?php
const WSU_AUTOLOADER_FILE = __DIR__ . '/vendor/autoload.php';

if( is_readable(WSU_AUTOLOADER_FILE) ) {
    require_once WSU_AUTOLOADER_FILE;
}

// Initialize Timber.
if ( class_exists( 'Timber\Timber' ) ) {
    Timber\Timber::init();
}
