#!/usr/bin/env bash
## reindex placeholder
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/reindex.sh

source $(dirname $(readlink -f $0))/script_begin.sh

fxHeader "🗂️ reindex"

fxCatastrophicError "reindex.sh is not ready!" dont-stop

echo "🧙 for Magento: replace this file with the one from https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/reindex.sh"

fxEndFooter failure
exit
