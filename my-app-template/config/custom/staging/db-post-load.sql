## Post-database load queries
#
# The following queries are executed automatically by `scripts/db-load.sh`
# after the database dump is loaded.
#
# ⚠️ This file runs both on STAGING and on DEV env ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/staging/db-post-load.sql

#UPDATE `core_config_data` SET `value` = 'https://next.my-app.com/' WHERE `path` IN('web/unsecure/base_url', 'web/secure/base_url');
#UPDATE `wp_options` SET `option_value` = 'https://next.my-app.com/' WHERE `option_name` IN('siteurl', 'home');
