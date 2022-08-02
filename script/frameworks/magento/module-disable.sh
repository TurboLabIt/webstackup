#!/usr/bin/env bash
## Standard Magento modules disable routine by WEBSTACKUP
#
# How to:
#
# 1. Set the module(s) you want to disable in your project `script_begin.sh`:
#  MAGENTO_MODULE_DISABLE="Magento_TwoFactorAuth Magento_Csp Mageplaza_Core"
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo script/magento-module-disable.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/magento/module-disable-starter.sh && sudo chmod u=rwx,go=rx script/magento-module-disable.sh
#
# 1. You should now git commit your copy
#

SCRIPT_NAME=module-disable
fxHeader "🧙🧹 Magento module-disable"

showPHPVer

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

cd "$MAGENTO_DIR"

if [ -z "${MAGENTO_MODULE_DISABLE}" ]; then

  fxCatastrophicError "📁 MAGENTO_MODULE_DISABLE not set"
  
else

  fxTitle "⚙️ Disabling modules ${MAGENTO_MODULE_DISABLE}..."
  wsuMage module:disable --clear-static-content ${MAGENTO_MODULE_DISABLE}
fi
