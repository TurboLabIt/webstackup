#!/usr/bin/env bash
## Standard Symfony database migration routine by WEBSTACKUP
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=symfony` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/migrate.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/migrate.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

fxHeader "🚚 Symfony database migration script"

if [ ! -d "${PROJECT_DIR}vendor/doctrine/doctrine-migrations-bundle" ]; then
  fxWarning "Doctrine Migrations not installed: nothing to migrate"
else
  wsuSymfony console doctrine:migrations:migrate --no-interaction
fi
