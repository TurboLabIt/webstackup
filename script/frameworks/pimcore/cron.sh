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


fxTitle "Segment Building Queue"
# Handles the calculation of asynchronous segments by processing the segment building queue. 
# This is needed for segments which could not be calculated directly for performance reasons
# https://pimcore.com/docs/customer-management-framework/current/Cronjobs.html#page_Segment-Building-Queue
wsuSymfony console cmf:build-segments -v


fxTitle "Action trigger queue"
# Handles the execution of delayed actions in ActionTrigger rules.
# https://pimcore.com/docs/customer-management-framework/current/Cronjobs.html#page_Action-trigger-queue
wsuSymfony console cmf:process-actiontrigger-queue -v

fxTitle "Cron Trigger"
# This cronjob is needed if cron triggers are used in ActionTrigger rules.
# Important: this needs to run once per minute!
# https://pimcore.com/docs/customer-management-framework/current/Cronjobs.html#page_Cron-Trigger
wsuSymfony console cmf:handle-cron-triggers -v

fxTitle "Calculate potential duplicates"
# Analyzes the duplicates index and calculates potential duplicates which will be shown in the potential duplicates list view.
# https://pimcore.com/docs/customer-management-framework/current/Cronjobs.html#page_Calculate-potential-duplicates
wsuSymfony console cmf:duplicates-index -c -v

fxTitle "CMF Maintenance"
# This cronjob should be configured to be executed on a regular basis. 
# It performs various tasks configured in services.yml and tagged with cmf.maintenance.serviceCalls.
# https://pimcore.com/docs/customer-management-framework/current/Cronjobs.html#page_CMF-Maintenance
wsuSymfony console cmf:maintenance -v

fxTitle "Newsletter Queue"
# Processes the newsletter queue. 
# This job should run once every x minutes (e.g. every 5 minutes) when the newsletter/mailchimp sync feature is needed.
# https://pimcore.com/docs/customer-management-framework/current/Cronjobs.html#page_Newsletter-Queue
wsuSymfony console cmf:newsletter-sync -c

fxTitle "Mailchimp status sync"
# Should run as a night job. Synchronizes status updates from Mailchimp to Pimcore if webhook calls failed. 
# This is important to ensure data integrity also when the system is down for several hours.
# https://pimcore.com/docs/customer-management-framework/current/Cronjobs.html#page_Newsletter-Queue
wsuSymfony console cmf:newsletter-sync -m
