### AUTOMATIC SYMFONY SETUP BY WEBSTACK.UP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/symfony-install.sh

fxHeader "💿 Symfony installer"
rootCheck

WSU_TMP_DIR=/tmp/wsu-symfony-installer/
rm -rf "${WSU_TMP_DIR}"
mkdir -p "${WSU_TMP_DIR}"
cd "${WSU_TMP_DIR}"

symfony new ${APP_NAME}
cd ${APP_NAME}

curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore

symfony composer require \
  twig cache asset \
  doctrine mailer webpack-encore-bundle \
  stof/doctrine-extensions-bundle
  
symfony composer require maker debug --dev

echo "
stof_doctrine_extensions:
   orm:
      default:
          timestampable: true
" > /dev/null
#config/packages/stof_doctrine_extensions.yml

symfony composer config repositories.TurboLabIt/TLIBaseBundle git https://github.com/TurboLabIt/TLIBaseBundle.git
symfony composer require turbolabit/tli-base-bundle:dev-master

composer config repositories.TurboLabIt/php-foreachable git https://github.com/TurboLabIt/php-foreachable.git
composer require turbolabit/php-foreachable:dev-main

composer config repositories.TurboLabIt/php-encryptor git https://github.com/TurboLabIt/php-encryptor.git
composer require turbolabit/php-encryptor:dev-main

composer config repositories.TurboLabIt/php-doctrine-runtime-manager git https://github.com/TurboLabIt/php-doctrine-runtime-manager.git
composer require turbolabit/php-doctrine-runtime-manager:dev-main

symfony composer config repositories.TurboLabIt/BaseCommand git https://github.com/TurboLabIt/php-symfony-basecommand.git
symfony composer require turbolabit/php-symfony-basecommand:dev-main

rm -rf .git

rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
