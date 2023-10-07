### Create a new Symfony project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/symfony-install.sh

fxHeader "🆕 symfony new"
rootCheck

if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ]; then

  catastrophicError "Symfony new can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  PROJECT_DIR:             ##${PROJECT_DIR}##"
  exit
fi

CURRENT_DIR_BACKUP=$(pwd)


fxTitle "Setting up temp directory..."
WSU_TMP_DIR=/tmp/wsu-symfony-new/
rm -rf "${WSU_TMP_DIR}"
mkdir -p "${WSU_TMP_DIR}"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WSU_TMP_DIR}"

PROJECT_DIR_BACKUP=${PROJECT_DIR}
PROJECT_DIR=${WSU_TMP_DIR}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"
cd ${PROJECT_DIR}


wsuSymfony new ${APP_NAME} --no-git

PROJECT_DIR=${WSU_TMP_DIR}${APP_NAME}/

wsuSymfony composer config extra.symfony.allow-contrib true
wsuSymfony composer config extra.symfony.docker true


# https://github.com/TurboLabIt/php-foreachable
wsuSymfony composer config repositories.turbolabit/php-foreachable git https://github.com/TurboLabIt/php-foreachable.git

# https://github.com/TurboLabIt/php-symfony-basecommand
wsuSymfony composer config repositories.turbolabit/php-symfony-basecommand git https://github.com/TurboLabIt/php-symfony-basecommand.git

# https://github.com/TurboLabIt/php-doctrine-runtime-manager
wsuSymfony composer config repositories.turbolabit/php-doctrine-runtime-manager git https://github.com/TurboLabIt/php-doctrine-runtime-manager.git

# https://github.com/TurboLabIt/php-encryptor
wsuSymfony composer config repositories.turbolabit/php-encryptor git https://github.com/TurboLabIt/php-encryptor.git

# https://github.com/TurboLabIt/php-dev-pack
wsuSymfony composer config repositories.turbolabit/php-dev-pack git https://github.com/TurboLabIt/php-dev-pack.git


wsuSymfony composer require \
  symfony/twig-pack symfony/cache symfony/asset \
  symfony/orm-pack symfony/mailer \
  symfony/webpack-encore-bundle \
  stof/doctrine-extensions-bundle \
  symfony/expression-language \
  symfony/monolog-bundle \
  form validator \
  turbolabit/php-foreachable:dev-main turbolabit/php-symfony-basecommand:dev-main \
  turbolabit/php-doctrine-runtime-manager:dev-main turbolabit/php-encryptor:dev-main \
  turbolabit/php-dev-pack:dev-master
  
 
fxTitle "Setting up doctrine-extensions..."
echo "
stof_doctrine_extensions:
   orm:
      default:
          timestampable: true
" > /dev/null
#config/packages/stof_doctrine_extensions.yml


wsuSymfony composer require symfony/maker-bundle symfony/debug-pack --dev


fxTitle "Adding .gitignore..."
curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore


fxTitle "Adding webpack stuff..."
sudo -u $EXPECTED_USER -H yarn add sass-loader sass file-loader
sudo -u $EXPECTED_USER -H yarn install
sudo -u $EXPECTED_USER -H yarn webpack


fxTitle "Restoring PROJECT_DIR"
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"

fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"


cd "${CURRENT_DIR_BACKUP}"
