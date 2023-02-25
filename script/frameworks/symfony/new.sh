### Create a new Symfony project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/symfony-install.sh

fxHeader "💿 symfony new"
rootCheck


if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ]; then

  catastrophicError "Symfony new can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  PROJECT_DIR:             ##${PROJECT_DIR}##"
  exit
fi


PROJECT_DIR_BACKUP=${PROJECT_DIR}
CURRENT_DIR_BACKUP=$(pwd)

fxTitle "Setting up temp directory..."
WSU_TMP_DIR=/tmp/wsu-symfony-new/
rm -rf "${WSU_TMP_DIR}"
mkdir -p "${WSU_TMP_DIR}"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WSU_TMP_DIR}"

PROJECT_DIR=${WSU_TMP_DIR}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"


fxTitle "Running symfony new..."
wsuSymfony new ${APP_NAME} --no-git
cd ${APP_NAME}


fxTitle "Adding .gitignore..."
curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore


fxTitle "Adding Symfony components..."
wsuSymfony composer require \
  symfony/twig-pack symfony/cache symfony/asset \
  symfony/orm-pack symfony/mailer \
  symfony/webpack-encore-bundle \
  stof/doctrine-extensions-bundle
  
 
fxTitle "Setting up doctrine-extensions..."
echo "
stof_doctrine_extensions:
   orm:
      default:
          timestampable: true
" > /dev/null
#config/packages/stof_doctrine_extensions.yml


fxTitle "Adding Symfony dev components..."
wsuSymfony composer require symfony/maker-bundle symfony/debug-pack --dev


fxTitle "Adding TurboLab.it packages..."
# https://github.com/TurboLabIt/php-foreachable
wsuSymfony composer config repositories.turbolabit/php-foreachable git https://github.com/TurboLabIt/php-foreachable.git
wsuSymfony composer require turbolabit/php-foreachable:dev-main

# https://github.com/TurboLabIt/php-symfony-basecommand
wsuSymfony composer config repositories.turbolabit/php-symfony-basecommand git https://github.com/TurboLabIt/php-symfony-basecommand.git
wsuSymfony composer require turbolabit/php-symfony-basecommand:dev-main

# https://github.com/TurboLabIt/php-doctrine-runtime-manager
wsuSymfony composer config repositories.turbolabit/php-doctrine-runtime-manager git https://github.com/TurboLabIt/php-doctrine-runtime-manager.git
wsuSymfony composer require turbolabit/php-doctrine-runtime-manager:dev-main

# https://github.com/TurboLabIt/php-encryptor
wsuSymfony composer config repositories.turbolabit/php-encryptor git https://github.com/TurboLabIt/php-encryptor.git
wsuSymfony composer require turbolabit/php-encryptor:dev-main

# https://github.com/TurboLabIt/php-dev-pack
wsuSymfony composer config repositories.turbolabit/php-dev-pack git https://github.com/TurboLabIt/php-dev-pack.git
wsuSymfony composer require turbolabit/php-dev-pack:dev-master


fxTitle "Restoring PROJECT_DIR"
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"


fxTitle "👮 Setting permissions..."
chmod ugo= "${PROJECT_DIR}" -R
chmod u=rwx,go=rX "${PROJECT_DIR}" -R
chmod go=rwX "${PROJECT_DIR}var" -R

fxTitle "👮 Setting the owner..."
chown ${EXPECTED_USER}:www-data "${PROJECT_DIR}" -R


fxTitle "📂 Listing PROJECT_DIR ##${PROJECT_DIR}#"
ls -la --color=always "${PROJECT_DIR}"


cd "${CURRENT_DIR_BACKUP}"
