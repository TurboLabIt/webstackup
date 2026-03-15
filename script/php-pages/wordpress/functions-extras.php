<?php
//<editor-fold defaultstate="collapsed" desc="*** 🛑 ABSPATH check ***">
if( !defined('ABSPATH') ) {
    exit;
}
//</editor-fold>


//<editor-fold defaultstate="collapsed" desc="*** 📦 composer autoloader ***">
const WSU_AUTOLOADER_FILE = __DIR__ . '/vendor/autoload.php';

if( is_readable(WSU_AUTOLOADER_FILE) ) {
    require_once WSU_AUTOLOADER_FILE;
}
//</editor-fold>


//<editor-fold defaultstate="collapsed" desc="*** 🪵 Timber (Twig) ***">
if ( class_exists( 'Timber\Timber' ) ) {
    Timber\Timber::init();
}
//</editor-fold>


//<editor-fold defaultstate="collapsed" desc="*** 📣 Remove WordPress Events and News ***">
// This prevents the UI from rendering AND stops the external HTTP requests to WordPress.org.
if ( is_admin() ) {
    add_action( 'wp_dashboard_setup', function() {
        remove_meta_box( 'dashboard_primary', 'dashboard', 'side' );
    }, 999 );
}
//</editor-fold>


//<editor-fold defaultstate="collapsed" desc="*** Remove Comments links ***">
if ( get_option( 'default_comment_status' ) != 'open' ) {

    // Conditionally remove "Comments" from the top admin bar if the comments are disabled (renders on frontend too)
    add_action( 'wp_before_admin_bar_render', function() {
        global $wp_admin_bar;
        $wp_admin_bar->remove_menu( 'comments' );
    } );

    // Conditionally remove the Comments UI from admin ONLY if comments are closed by default
    if ( is_admin() ) {

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
}
//</editor-fold>


//<editor-fold defaultstate="collapsed" desc="*** 📦 Webpack ***">
/**
 * Utility to dynamically find and return the URL of a hashed Webpack asset.
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
 * Enqueue the theme's CSS and JS files.
 */
function wsu_theme_enqueue_assets()
{
    // 1. Enqueue the compiled SCSS -> CSS
    $css_url = get_webpack_hashed_asset('css', 'main.min', 'css');
    if ($css_url) {
        // Notice the 4th parameter (version) is 'null'.
        // We don't need WP's native ?ver= cache-busting because our filename has the hash!
        wp_enqueue_style('wsu-webpack-theme-style', $css_url, array(), null);
    }

    // 2. Enqueue the compiled JS
    $js_url = get_webpack_hashed_asset('js', 'main.min', 'js');
    if ($js_url) {
        // Load in footer (true) and declare jQuery as a dependency (since we excluded it in Webpack)
        wp_enqueue_script('wsu-webpack-theme-script', $js_url, array('jquery'), null, true);
    }
}

add_action('wp_enqueue_scripts', 'wsu_theme_enqueue_assets');
//</editor-fold>
