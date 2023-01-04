## 🚨 WARNING 🚨
#
# This file is under version control!
# DO NOT EDIT DIRECTLY - If you do, you'll loose your changes!
#
# The original file is in `/var/www/my-app/config/custom/staging/`
#
# You MUST:
#
# 1. edit the original file on you PC
# 2. Git-commit+push the changes
# 3. run `sudo bash /var/www/my-app/scripts/db-load.sh`
#
# ⚠️ This file is for the STAGING env only ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/staging/db-post-load.sql

#UPDATE `core_config_data` SET `value` = 'https://next.my-app.com/' WHERE `path` IN('web/unsecure/base_url', 'web/secure/base_url');
#UPDATE `wp_options` SET `option_value` = 'https://next.my-app.com/' WHERE `option_name` IN('siteurl', 'home');
