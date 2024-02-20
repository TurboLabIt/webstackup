#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/phpbb-cli.sh

source $(dirname $(readlink -f $0))/script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}frameworks/phpbb-cli.sh"
source "${SCRIPT_DIR}/script_end.sh"
