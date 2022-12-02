#!/usr/bin/env bash
## clear-cache placeholder
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/clear-cache.sh

source $(dirname $(readlink -f $0))/script_begin.sh

fxHeader "🧹 cache-clear"

fxCatastrophicError "cache-clear.sh is not ready!" dont-stop

echo "🧙 for Magento: replace this file with the one from https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/cache-clear.sh"
echo "📐 for Symfony: replace this file with the one from https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/symfony/cache-clear.sh"

fxEndFooter failure
exit
