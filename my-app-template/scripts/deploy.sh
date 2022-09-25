#!/usr/bin/env bash
## Run this script to start a deploy!
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/deploy.sh

# $1 deploy mode: fast or empty

SCRIPT_NAME=deploy
source $(dirname $(readlink -f $0))/script_begin.sh

sudo bash ${SCRIPT_DIR}deploy_run.sh $1 2>&1 | sudo tee ${PROJECT_DIR}var/log/deploy.sh.log
