#!/usr/bin/env bash
## Standard Symfony cron job by WEBSTACKUP
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=symfony` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cron.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/cron.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy
#
# After the next `deploy.sh`, the related cron file https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/cron will be activated

fxHeader "♾️ 🕰️ Symfony cron"
cd "${PROJECT_DIR}"

fxTitle "Running messenger:consume async..."
export XDEBUG_MODE="off"
sudo -u www-data -H symfony local:php:refresh
sudo -u www-data -H symfony console messenger:consume async -vv --time-limit=90
