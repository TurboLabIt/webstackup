## Magento upgrade/update routine by WEBSTACKUP
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=magento` in your project `script_begin.sh`
#
# 2. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/upgrade.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/upgrade.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 3. You should now git commit your copy
#
# 4. upgrade: bash scripts/upgrade.sh <new-version>
#
# 5. git-commit composer.json, composer.lock, other files

## Based on: https://experienceleague.adobe.com/en/docs/commerce-operations/upgrade-guide/implementation/perform-upgrade

fxHeader "🧙🆙 Upgrade Magento"

if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
  fxCatastrophicError "📁 MAGENTO_DIR not set"
fi

cd "$MAGENTO_DIR"


if [ -z "${MAGENTO_UPGRADE_TO_VERSION}" ]; then
  MAGENTO_UPGRADE_TO_VERSION=$1
fi

if [ -z "${MAGENTO_UPGRADE_TO_VERSION}" ]; then
  fxCatastrophicError "Provide the version to upgrade to: bash scripts/upgrade.sh 2.x.y-pZ"
fi

fxInfo "Upgrading to ##${MAGENTO_UPGRADE_TO_VERSION}##"


## Entering maintenance mode
wsuMage maintenance:enable

## Starting the upgrade process while asynchronous processes are running may cause data corruption.
fxTitle "Deleting Magento own cron file (we provide our own)..."
wsuMage cron:remove

fxTitle "Consuming Magento cron queue..."
wsuMage cron:run --group=consumers

## upgrade composer.json via Magento own composer plugin
composer require-commerce magento/ product-community-edition $MAGENTO_UPGRADE_TO_VERSION --no-update --force-root-updates #[--interactive-root-conflicts]

## regenerate composer.lock
composer update --with-all-dependencies


bash "${SCRIPT_DIR}cache-clear.sh"
