#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/deploy.sh

# $1: deploy mode (fast or <empty>)

SCRIPT_NAME=deploy
source $(dirname $(readlink -f $0))/script_begin.sh

sudo script -qe -c "bash ${SCRIPT_DIR}deploy_run.sh $1" "${PROJECT_DIR}var/log/deploy.sh.log"
