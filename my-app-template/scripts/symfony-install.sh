#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/symfony-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh
source ${WEBSTACKUP_SCRIPT_DIR}frameworks/symfony/new.sh
source "${SCRIPT_DIR}/script_end.sh"
