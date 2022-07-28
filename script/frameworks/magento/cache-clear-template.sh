#!/usr/bin/env bash
## Magento cache-clearing script by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/cache-clear-template.sh

# Copy this file to your project directory:
#   curl -Lo script/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/magento/cache-clear-template.sh && sudo chmod u=rwx,go=rx script/cache-clear.sh
# You should then git commit your copy
source $(dirname $(readlink -f $0))/script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}frameworks/magento/cache-clear.sh"
source "${SCRIPT_DIR}/script_end.sh"
