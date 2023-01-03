#!/usr/bin/env bash
## Framework-based database dump loader by WEBSTACKUP
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/db-load.sh

source $(dirname $(readlink -f $0))/script_begin.sh

DB_DUMP_FILE_PATH=${DB_DUMP_DIR}db_${APP_NAME}-prod_db-dump-sh.sql.gz
SKIP_POST_LOAD_QUERY=0

wsuSourceFrameworkScript db-load
