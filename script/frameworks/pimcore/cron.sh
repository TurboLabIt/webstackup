#!/usr/bin/env bash
## Standard Pimcore cron job by WEBSTACKUP
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=pimcore` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cron.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/cron.sh && sudo chmod u=rwx,go=rx scripts/cron.sh
#
# 1. You should now git commit your copy
#
# After the next `deploy.sh`, the related cron file https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/cron will be activated

fxHeader "♾️ 🕰️ Pimcore cron"

if [ -z "${LOCKFILE}" ]; then
  LOCKFILE=/tmp/pimcore-cron-${APP_NAME}
fi

lockCheck "${LOCKFILE}"

showPHPVer

fxTitle "pimcore:maintenance"
# this command needs to be executed via cron or similar task scheduler
# it fills the message queue with the necessary tasks, which are then processed by messenger:consume
wsuSymfony console pimcore:maintenance --async

fxTitle "messenger:consume"
# it's recommended to run the following command using a process control system like Supervisor
# please follow the Symfony Messenger guide for a best practice production setup:
# https://symfony.com/doc/current/messenger.html#deploying-to-production
wsuSymfony console messenger:consume pimcore_core pimcore_maintenance pimcore_image_optimize --time-limit=300
