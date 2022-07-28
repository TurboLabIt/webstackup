
#!/usr/bin/env bash
## Activate standard maintenace page by WEBSTACKUP
# Install instruction: https://github.com/TurboLabIt/webstackup/blob/master/script/nginx/maintenance.sh

source $(dirname $(readlink -f $0))/script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}nginx/maintenance.sh"
source "${SCRIPT_DIR}/script_end.sh"
