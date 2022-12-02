#!/usr/bin/env bash
## maintenance placeholder
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/maintenance.sh

source $(dirname $(readlink -f $0))/script_begin.sh

fxHeader "🧰 Maintenance"

fxCatastrophicError "maintenance.sh is not ready!" dont-stop

echo "🧙 for Magento: replace this file with the one from https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/maintenance.sh"
echo "📐 for any project: replace this file with the one from https://github.com/TurboLabIt/webstackup/blob/master/script/nginx/maintenance.sh"

fxEndFooter failure
exit
