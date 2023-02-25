### AUTOMATIC SYMFONY SETUP BY WEBSTACK.UP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/symfony-install.sh

fxHeader "💿 Symfony installer"
rootCheck

PROJECT_DIR_BACKUP=${PROJECT_DIR}

WSU_TMP_DIR=/tmp/wsu-symfony-new/
rm -rf "${WSU_TMP_DIR}"
mkdir -p "${WSU_TMP_DIR}"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WSU_TMP_DIR}"

PROJECT_DIR=${WSU_TMP_DIR}

wsuSymfony new ${APP_NAME} --no-git
cd ${APP_NAME}

curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore

wsuSymfony composer require \
  twig cache asset \
  doctrine mailer webpack-encore-bundle \
  stof/doctrine-extensions-bundle
  
wsuSymfony composer require maker debug --dev

echo "
stof_doctrine_extensions:
   orm:
      default:
          timestampable: true
" > /dev/null
#config/packages/stof_doctrine_extensions.yml

wsuSymfony composer config repositories.TurboLabIt/TLIBaseBundle git https://github.com/TurboLabIt/TLIBaseBundle.git
wsuSymfony composer require turbolabit/tli-base-bundle:dev-master

wsuSymfony config repositories.TurboLabIt/php-foreachable git https://github.com/TurboLabIt/php-foreachable.git
wsuSymfony require turbolabit/php-foreachable:dev-main

wsuSymfony config repositories.TurboLabIt/php-encryptor git https://github.com/TurboLabIt/php-encryptor.git
wsuSymfony require turbolabit/php-encryptor:dev-main

wsuSymfony config repositories.TurboLabIt/php-doctrine-runtime-manager git https://github.com/TurboLabIt/php-doctrine-runtime-manager.git
wsuSymfony require turbolabit/php-doctrine-runtime-manager:dev-main

wsuSymfony composer config repositories.TurboLabIt/BaseCommand git https://github.com/TurboLabIt/php-symfony-basecommand.git
wsuSymfony composer require turbolabit/php-symfony-basecommand:dev-main

PROJECT_DIR=${PROJECT_DIR_BACKUP}

fxTitle "👮 Setting permissions..."
chmod u=rwx,go=rX "${WSU_TMP_DIR}" -R
chmod u=rwx,go=rwX "${WSU_TMP_DIR}${APP_NAME}/var" -R

fxTitle "👮 Setting the owner..."
DIR_OWNER=$(fxGetFileOwner "${PROJECT_DIR}")
chown ${DIR_OWNER}:www-data "${WSU_TMP_DIR}" -R

rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
