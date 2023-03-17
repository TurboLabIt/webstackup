#!/usr/bin/env bash
# ⚠️ Don't run this script directly! Use `bash deploy.sh` instead.
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/deploy_run.sh

SCRIPT_NAME=deploy
source $(dirname $(readlink -f $0))/script_begin.sh
## https://github.com/TurboLabIt/webstackup/blob/master/script/filesystem/deploy_run.sh
source "${WEBSTACKUP_SCRIPT_DIR}filesystem/deploy_run.sh"
source "${SCRIPT_DIR}script_end.sh"
