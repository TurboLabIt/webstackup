## Post-database restore queries
#
# The following queries are executed automatically by `scripts/db-restore.sh`
# after the database dump is restored.
#
# ⚠️ This file is for the DEV env only ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/dev/db-post-restore.sql

## dev0
#USE my-app_dev0
#UPDATE `core_config_data` SET `value` = 'https://dev0-next.my-app.com/' WHERE `path` IN('web/unsecure/base_url', 'web/secure/base_url');
#UPDATE `wp_options` SET `option_value` = 'https://dev0-next.my-app.com/' WHERE `option_name` IN('siteurl', 'home');


## dev1
#USE my-app_dev1
#UPDATE `core_config_data` SET `value` = 'https://dev1-next.my-app.com/' WHERE `path` IN('web/unsecure/base_url', 'web/secure/base_url');
#UPDATE `wp_options` SET `option_value` = 'https://dev1-next.my-app.com/' WHERE `option_name` IN('siteurl', 'home');
