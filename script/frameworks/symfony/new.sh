### Create a new Symfony project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/symfony-install.sh

fxHeader "🆕 Symfony new"
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
echo "${PHP_VER}" > "${WSU_TMP_DIR}.php-version"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WSU_TMP_DIR}"

PROJECT_DIR_BACKUP=${PROJECT_DIR}
PROJECT_DIR=${WSU_TMP_DIR}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"
cd ${PROJECT_DIR}


wsuSymfony new ${APP_NAME} --no-git
PROJECT_DIR=${WSU_TMP_DIR}${APP_NAME}/
mv "${WSU_TMP_DIR}.php-version" "${PROJECT_DIR}"


wsuSymfony composer config minimum-stability dev --no-interaction
wsuSymfony composer config prefer-stable true --no-interaction

wsuSymfony composer config extra.symfony.allow-contrib true --no-interaction
wsuSymfony composer config extra.symfony.docker false --no-interaction

fxTitle "📦 composer req"
wsuSymfony composer require --no-interaction \
  symfony/twig-pack symfony/cache symfony/asset \
  symfony/orm-pack symfony/mailer \
  symfony/webpack-encore-bundle \
  stof/doctrine-extensions-bundle \
  symfony/expression-language \
  form validator \
  symfony/monolog-bundle \
  turbolabit/php-foreachable:dev-main turbolabit/php-encryptor turbolabit/php-symfony-basecommand:dev-main \
  turbolabit/php-symfony-messenger:dev-main turbolabit/paginatorbundle:dev-main turbolabit/service-entity-plus-bundle:dev-main
  
 
fxTitle "Setting up doctrine-extensions..."
echo "
stof_doctrine_extensions:
   orm:
      default:
          timestampable: true
" > /dev/null
#config/packages/stof_doctrine_extensions.yml


fxTitle "📦 composer req DEV-only"
wsuSymfony composer require --no-interaction --dev \
  symfony/maker-bundle symfony/debug-pack phpunit brianium/paratest


fxTitle "Adding .gitignore..."
## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore
curl -O https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore

## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore_symfony
curl -o "${PROJECT_DIR}backup/.gitignore_symfony_temp" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore_symfony
sed -i "s/my-app/${APP_NAME}/g" "${PROJECT_DIR}backup/.gitignore_symfony_temp"
echo "" >> "${PROJECT_DIR}.gitignore"
cat "${PROJECT_DIR}backup/.gitignore_symfony_temp" >> "${PROJECT_DIR}.gitignore"
rm -f "${PROJECT_DIR}backup/.gitignore_symfony_temp"


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
