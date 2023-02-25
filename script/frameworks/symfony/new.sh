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
  symfony/twig-pack symfony/cache symfony/asset \
  symfony/orm-pack symfony/mailer \
  symfony/webpack-encore-bundle \
  stof/doctrine-extensions-bundle
  
wsuSymfony composer require symfony/maker-bundle symfony/debug-pack --dev

echo "
stof_doctrine_extensions:
   orm:
      default:
          timestampable: true
" > /dev/null
#config/packages/stof_doctrine_extensions.yml

wsuSymfony composer config repositories.turbolabit/php-dev-pack git https://github.com/TurboLabIt/php-dev-pack.git
wsuSymfony composer require turbolabit/php-dev-pack:dev-master

PROJECT_DIR=${PROJECT_DIR_BACKUP}

fxTitle "👮 Setting permissions..."
chmod u=rwx,go=rX "${WSU_TMP_DIR}" -R
chmod u=rwx,go=rwX "${WSU_TMP_DIR}${APP_NAME}/var" -R

fxTitle "👮 Setting the owner..."
DIR_OWNER=$(fxGetFileOwner "${PROJECT_DIR}")
chown ${DIR_OWNER}:www-data "${WSU_TMP_DIR}" -R

rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
