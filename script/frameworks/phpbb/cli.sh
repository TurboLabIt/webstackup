fxHeader "💬 phpBB bin/phpbbcli.php"
cd "${WEBROOT_DIR}forum"
sudo -u www-data -H XDEBUG_MODE=off ${PHP_CLI} bin/phpbbcli.php "$@"

