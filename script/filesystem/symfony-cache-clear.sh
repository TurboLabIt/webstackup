#!/usr/bin/env bash
SCRIPT_NAME=symfony-cache-clear

source $(dirname $(readlink -f $0))/script_begin.sh
printHeader "🧹 cache-clear"

if [ -d "${PROJECT_DIR}var/cache" ]; then
  rm -rf "${PROJECT_DIR}var/cache"
fi

sudo -u "${EXPECTED_USER}" -H symfony console cache:clear

sudo service php${PHP_VER}-fpm restart

source $(dirname $(readlink -f $0))/script_end.sh
