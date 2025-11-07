## 🚨 WARNING 🚨
#
# This file is under version control!
# DO NOT EDIT DIRECTLY - If you do, you'll loose your changes!
#
# The original file is in `/var/www/my-app/scripts/`
#
# You MUST:
#
# 1. edit the original file on you PC
# 2. Git-commit+push the changes
# 3. add this to your cache-clear: source "${WEBSTACKUP_SCRIPT_DIR}account/bashrc-dev-patch.sh"
#
# ⚠️ This file is for the DEV env only ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/bashrc-dev.sh

## this should be sourced from each user .bashrc

if [ "$(logname)" == "dev0" ]; then

  export XDEBUG_PORT=9008
  cd /var/www/dev0/my-app

elif [ "$(logname)" == "dev1" ]; then

  export XDEBUG_PORT=9009
  cd /var/www/dev1/my-app

fi


if [ -z "${XDEBUG_PORT}" ]; then
  fxInfo "Xdebug enabled on port $XDEBUG_PORT 🐛"
fi
