<?php
if( !defined('ABSPATH') ) {
    exit;
}

// composer autoloader
const WSU_AUTOLOADER_FILE = __DIR__ . '/vendor/autoload.php';

if( is_readable(WSU_AUTOLOADER_FILE) ) {
    require_once WSU_AUTOLOADER_FILE;
}


// Initialize Timber.
if ( class_exists( 'Timber\Timber' ) ) {
    Timber\Timber::init();
}


// Conditionally remove "Comments" from the top admin bar if the comments are disabled (renders on frontend too)
if ( get_option( 'default_comment_status' ) === 'closed' ) {
    add_action( 'wp_before_admin_bar_render', function() {
        global $wp_admin_bar;
        $wp_admin_bar->remove_menu( 'comments' );
    } );
}


/**
 * Completely remove the "WordPress Events and News" dashboard widget.
 * This prevents the UI from rendering AND stops the external HTTP requests to WordPress.org.
 */
if ( is_admin() ) {
    add_action( 'wp_dashboard_setup', function() {
        remove_meta_box( 'dashboard_primary', 'dashboard', 'side' );
    }, 999 );
}


/**
 * Conditionally remove the Comments UI from admin ONLY if comments are closed by default
 */
if ( is_admin() && get_option( 'default_comment_status' ) === 'closed' ) {

    // Remove "Comments" from the left admin sidebar
    add_action( 'admin_menu', function() {
        remove_menu_page( 'edit-comments.php' );
    } );

    // Redirect any user who tries to manually visit the comments page
    add_action( 'admin_init', function() {
        global $pagenow;
        if ( $pagenow === 'edit-comments.php' ) {
            wp_safe_redirect( admin_url() );
            exit;
        }
    } );
}


/**
 * WEBPACK - Utility to dynamically find and return the URL of a hashed Webpack asset.
 * @param string $directory The sub-directory inside build (e.g., 'js' or 'css').
 * @param string $prefix The base name of the file (e.g., 'main.min').
 * @param string $extension The file extension (e.g., 'js' or 'css').
 * @return string|bool      The file URL, or false if not found.
 */
function get_webpack_hashed_asset($directory, $prefix, $extension)
{
    $theme_dir = get_template_directory();
    $theme_uri = get_template_directory_uri();

    // Construct the absolute path pattern: /.../wp-content/themes/my-theme/assets/build/js/main.min.*.js
    $pattern = sprintf('%s/assets/build/%s/%s.*.%s', $theme_dir, $directory, $prefix, $extension);

    // glob() returns an array of files matching the pattern
    $files = glob($pattern);

    if (!empty($files) && is_array($files)) {
        // Grab the first matched file
        $absolute_path = $files[0];

        // Swap the server directory path for the public URI
        return str_replace($theme_dir, $theme_uri, $absolute_path);
    }

    return false;
}


/**
 * WEBPACK - Enqueue the theme's CSS and JS files.
 */
function wsu_theme_enqueue_assets()
{
    // 1. Enqueue the compiled SCSS -> CSS
    $css_url = get_webpack_hashed_asset('css', 'main.min', 'css');
    if ($css_url) {
        // Notice the 4th parameter (version) is 'null'.
        // We don't need WP's native ?ver= cache-busting because our filename has the hash!
        wp_enqueue_style('my-theme-style', $css_url, array(), null);
    }

    // 2. Enqueue the compiled JS
    $js_url = get_webpack_hashed_asset('js', 'main.min', 'js');
    if ($js_url) {
        // Load in footer (true) and declare jQuery as a dependency (since we excluded it in Webpack)
        wp_enqueue_script('my-theme-script', $js_url, array('jquery'), null, true);
    }
}

add_action('wp_enqueue_scripts', 'wsu_theme_enqueue_assets');
