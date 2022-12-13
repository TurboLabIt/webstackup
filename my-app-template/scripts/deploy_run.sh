#!/usr/bin/env bash
## Main deploy script.
#
# ⚠️ Don't run this script directly! Use `bash deploy.sh` instead.
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/deploy_run.sh

SCRIPT_NAME=deploy
source $(dirname $(readlink -f $0))/script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}filesystem/deploy_run.sh"
source $(dirname $(readlink -f $0))/script_end.sh
