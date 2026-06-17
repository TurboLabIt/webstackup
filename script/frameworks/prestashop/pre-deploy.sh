fxTitle "Enabling OPcache timestamp revalidation (PrestaShop-safe)..."
## The global 30-webstackup-opcache.ini sets opcache.validate_timestamps=0 (OPcache never
## re-checks files on disk). That's unsafe for PrestaShop, which regenerates its own PHP files
## (compiled Smarty templates, var/cache) without reloading php-fpm. Symlink the override into
## conf.d as 35-* so it loads after (and wins over) 30-webstackup-opcache.ini.
fxLink "${WEBSTACKUP_INSTALL_DIR}config/php/opcache-revalidate-timestamp.ini" \
  "/etc/php/${PHP_VER}/fpm/conf.d/35-webstackup-opcache-revalidate-timestamp.ini"
