#!/usr/bin/env bash
## env init script.
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/script_begin.sh
echo ""

## Fix path (for cron)
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

## https://github.com/TurboLabIt/webstackup/blob/master/script/base.sh
source "/usr/local/turbolab.it/webstackup/script/base.sh"
fxCatastrophicError "script_begin.sh is not ready! Please customize it and remove this line when done"
APP_NAME="my-app"
PRIVGEN_DIR="/var/www/private_generics/"
USERS_TEMPLATE_PATH="${PRIVGEN_DIR}operations/accounts/my-company/"
ZZ_CMD_SUFFIX=0

## for Magento only (remove if this is NOT a Magento-based app)
MAGENTO_DIR=${PROJECT_DIR}shop/
WEBROOT_DIR=${MAGENTO_DIR}pub/
MAGENTO_STATIC_CONTENT_DEPLOY="DevCompany/my-app en_US it_IT fr_FR de_DE en_GB es_ES"
MAGENTO_MODULE_DISABLE="Magento_TwoFactorAuth Magento_Csp Mageplaza_Core Magento_LoginAsCustomerGraphQl Magento_LoginAsCustomerAssistance"
COMPOSER_JSON_FULLPATH=${MAGENTO_DIR}composer.json
COMPOSER_SKIP_DUMP_AUTOLOAD=1

## for Symfony or any other standard web app
## ... init your own variables ... ##

## Enviroment variables and checks
if [ "$APP_ENV" = "prod" ]; then

  EXPECTED_USER=webstackup
  SITE_URL=https://my-app.com/
  EMOJI=⚡
  LOCAL_CONFIG_DIR=${PROJECT_DIR}config/custom/prod/

elif [ "$APP_ENV" = "staging" ]; then

  EXPECTED_USER=webstackup
  SITE_URL=https://next.my-app.com/
  EMOJI=🧪
  LOCAL_CONFIG_DIR=${PROJECT_DIR}config/custom/staging/

elif [[ "$APP_ENV" == "dev"* ]]; then

  EXPECTED_USER=$(logname)
  SITE_URL=https://my-app.wip/
  EMOJI=👨🏻‍💻
  LOCAL_CONFIG_DIR=${PROJECT_DIR}config/custom/dev/

else

  fxCatastrophicError "Unhandled env ##$APP_ENV## (branch: ##$GIT_BRANCH##)"
fi

cd $PROJECT_DIR
