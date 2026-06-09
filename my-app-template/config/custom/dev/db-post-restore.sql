## Post-database restore queries
#
# The following queries are executed automatically by `scripts/db-restore.sh`
# after the database dump is restored.
#
# ⚠️ This file is for the DEV env only ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/dev/db-post-restore.sql

#USE my-app_dev0;
#MAGENTO: UPDATE `core_config_data` SET `value` = 'https://dev0-next.my-app.com/' WHERE `path` IN('web/unsecure/base_url', 'web/secure/base_url');
#WORDPRESS: UPDATE `wp_options` SET `option_value` = 'https://dev0-next.my-app.com/' WHERE `option_name` IN('siteurl', 'home');
#WORDPRESS: UPDATE `wp_blogs` SET `domain` = 'dev0-next.my-app.com' WHERE `blog_id` = 1;
#WORDPRESS: UPDATE `wp_usermeta` SET `meta_value` = 'disabled' WHERE `meta_key` = 'googleauthenticator_enabled';


#USE my-app_dev1;
#...
