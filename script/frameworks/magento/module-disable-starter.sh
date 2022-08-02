#!/usr/bin/env bash
## Disable Magento modules by WEBSTACKUP
# Install instruction: https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/module-disable.sh

source $(dirname $(readlink -f $0))/script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}frameworks/magento/module-disable.sh"
source "${SCRIPT_DIR}/script_end.sh"
