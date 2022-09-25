#!/usr/bin/env bash
## env closing script.
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/script_end.sh

removeLock "${LOCKFILE}"
fxEndFooter
exit
