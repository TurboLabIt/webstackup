## Standard Magento script init by WEBSTACKUP.
# Sourced by https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/script_begin.sh

MAGENTO_DIR=${PROJECT_DIR}shop/
WEBROOT_DIR=${MAGENTO_DIR}pub/
MAGENTO_MODULE_DISABLE="Magento_TwoFactorAuth Magento_Csp Mageplaza_Core Magento_LoginAsCustomerGraphQl Magento_LoginAsCustomerAssistance"
COMPOSER_JSON_FULLPATH=${MAGENTO_DIR}composer.json
COMPOSER_SKIP_DUMP_AUTOLOAD=1
