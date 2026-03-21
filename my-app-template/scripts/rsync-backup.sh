#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/rsync-backup.sh

source $(dirname $(readlink -f $0))/script_begin.sh

RSYNC_BACKUP_TARGET="${PROJECT_DIR}backup/rsync-backup/"
mkdir -p "${RSYNC_BACKUP_TARGET}"

wsuMirror example.com:/home "${RSYNC_BACKUP_TARGET}"
wsuMirror example.com:/etc "${RSYNC_BACKUP_TARGET}"

source "${SCRIPT_DIR}script_end.sh"
