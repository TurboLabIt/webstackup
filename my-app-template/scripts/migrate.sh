#!/usr/bin/env bash
## migrate placeholder
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/migrate.sh

source $(dirname $(readlink -f $0))/script_begin.sh

fxHeader "🚕 migrate"

fxCatastrophicError "migrate.sh is not ready!" dont-stop

echo "🧙 for Magento: https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/migrate.sh"
echo "📐 for Symfony: https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/symfony/migrate.sh"

fxEndFooter failure
exit
