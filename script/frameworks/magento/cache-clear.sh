#!/usr/bin/env bash
## Standard Magento cache-clearing routine by WEBSTACKUP
#
# To be used via https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/cache-clear-template.sh

SCRIPT_NAME=magento-cache-clear
fxHeader "🧹 cache-clear"

showPHPVer

fxTitle "Stopping services.."
sudo nginx -t && sudo service nginx stop && sudo service ${PHP_FPM} stop

wsuMage cache:flush

fxTitle "Restarting services.."
sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart
