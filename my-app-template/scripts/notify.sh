#!/usr/bin/env bash
## team notifier
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/notify.sh

source $(dirname $(readlink -f $0))/script_begin.sh
source "${PRIVGEN_DIR}operations/webstackup/notify.sh"
source $(dirname $(readlink -f $0))/script_end.sh
