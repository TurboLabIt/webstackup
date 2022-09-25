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
# ⚠️ This file is SHARED among staging|prod ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/zzcd_bookmarks.sh
#
fxCatastrophicError "zzcd_bookmarks.sh is not ready! Please customize it and remove this line when done"
PROJECT_DIR=/var/www/my-app/
ZZCD_BOOKMARKS=("${PROJECT_DIR}" "Go"
  "${PROJECT_DIR}var/log" "Go"
  "/var/log/nginx/" "Go"
  "/var/www/" "Go"
  "/etc/nginx/conf.d" "Go")
