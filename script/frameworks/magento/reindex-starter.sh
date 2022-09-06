#!/usr/bin/env bash
## Magento reindex script by WEBSTACKUP
# Install instruction: https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/reindex.sh

source $(dirname $(readlink -f $0))/script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}frameworks/magento/reindex.sh"
source "${SCRIPT_DIR}/script_end.sh"
