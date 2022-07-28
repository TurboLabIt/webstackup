#!/usr/bin/env bash
## Magento cache-clearing script by WEBSTACKUP
# Install instruction: https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/cache-clear.sh

source $(dirname $(readlink -f $0))/script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}frameworks/magento/cache-clear.sh"
source "${SCRIPT_DIR}/script_end.sh"
