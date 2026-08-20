## 🚨 WARNING 🚨
#
# This file is under version control!
# DO NOT EDIT DIRECTLY - If you do, you'll lose your changes!
#
# The original file is in `/var/www/my-app/scripts/`
#
# You MUST:
#
# 1. edit the original file on your PC
# 2. Git-commit+push the changes
# 3. run `sudo bash /var/www/my-app/scripts/deploy.sh`
#
# ⚠️ This file is SHARED among staging|prod ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/zzcd_bookmarks.sh
#
PROJECT_DIR=/var/www/my-app/
ZZCD_BOOKMARKS=(
  "${PROJECT_DIR}" "📌"
  "${PROJECT_DIR}public" "🌐"
  "${PROJECT_DIR}config/custom" "🛠️"
  "${PROJECT_DIR}var/log" "📜"
  "/var/log/nginx" "📜"
  "/etc/cron.d" "🕒"
  "/etc/nginx/conf.d" "🛠️"
  "/etc/turbolab.it" "🧩"
  "$HOME" "🏠"
  "/root" "👑"
)
