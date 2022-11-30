#!/usr/bin/env bash
## phpbb-upgrade
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/phpbb-upgrade.sh

source $(dirname $(readlink -f $0))/script_begin.sh
bash /usr/local/turbolab.it/phpbb-upgrader/phpbb-upgrader.sh my-app
## ... run your own post-update tasks ... ##
source "${SCRIPT_DIR}/script_end.sh"
