#!/usr/bin/env bash
## Symfony cache-clearing script by WEBSTACKUP
# Install instruction: https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/symfony/cache-clear.sh

source $(dirname $(readlink -f $0))/script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}frameworks/symfony/cache-clear.sh"
source "${SCRIPT_DIR}/script_end.sh"
