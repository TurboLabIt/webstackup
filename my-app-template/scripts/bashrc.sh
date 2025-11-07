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
# 3. run `sudo bash /var/www/my-app/scripts/deploy.sh`
#
# ⚠️ This file is SHARED among dev|staging|prod ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/bashrc.sh

## this should be sourced from each user .bashrc

source "/usr/local/turbolab.it/bash-fx/scripts/colors.sh"
fxSetBackgroundColorByHostAndEnv "my-app.com" "prod"
fxSetBackgroundColorByHostAndEnv "next.my-app.com" "next"
trap fxResetBackgroundColor EXIT

cd /var/www/my-app
