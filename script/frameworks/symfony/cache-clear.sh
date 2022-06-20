#!/usr/bin/env bash
## Standard Symfony cache-clearing routine by WEBSTACKUP
# printTitle "💫 Copying Symfony scripts from webstackup..."
# cp "${WEBSTACKUP_SCRIPT_DIR}frameworks/symfony/cache-clear.sh" "${SCRIPT_DIR}"

SCRIPT_NAME=symfony-cache-clear

source $(dirname $(readlink -f $0))/script_begin.sh
printHeader "🧹 cache-clear"

sudo service nginx -t && sudo service nginx stop
sudo service php${PHP_VER}-fpm stop

sudo rm -rf "${PROJECT_DIR}var/cache"
sudo -u "${EXPECTED_USER}" -H symfony console cache:clear

sudo service php${PHP_VER}-fpm restart
sudo service nginx -t && sudo service nginx restart

source $(dirname $(readlink -f $0))/script_end.sh
