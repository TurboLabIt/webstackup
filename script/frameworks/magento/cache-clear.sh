#!/usr/bin/env bash
## Standard Magento cache-clearing routine by WEBSTACKUP
#
# How to:
# Copy this file to your project directory with:
#   curl -Lo script/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/magento/cache-clear-template.sh && sudo chmod u=rwx,go=rx script/cache-clear.sh
# You should then git commit your copy

SCRIPT_NAME=magento-cache-clear
fxHeader "🧹 cache-clear"

showPHPVer

fxTitle "Stopping services.."
sudo nginx -t && sudo service nginx stop && sudo service ${PHP_FPM} stop

wsuMage cache:flush

fxTitle "Restarting services.."
sudo nginx -t && sudo service ${PHP_FPM} restart && sudo service nginx restart
