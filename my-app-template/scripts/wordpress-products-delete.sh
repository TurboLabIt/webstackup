#!/usr/bin/env bash

source $(dirname $(readlink -f $0))/script_begin.sh
## https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/wordpress/products-delete.sh
source "${WEBSTACKUP_SCRIPT_DIR}frameworks/wordpress/products-delete.sh"
bash "${SCRIPT_DIR}cache-clear.sh"
