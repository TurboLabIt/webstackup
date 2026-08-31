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


fxTitle "🛟 Backing up the original composer.json..."
if [ ! -f "${PROJECT_DIR}var/symfony_composer_original.json" ]; then
  mkdir -p "${PROJECT_DIR}var"
  cp "${PROJECT_DIR}composer.json" "${PROJECT_DIR}var/symfony_composer_original.json"
  fxOK "Saved to ##var/symfony_composer_original.json##"
else
  fxInfo "##var/symfony_composer_original.json## already exists"
fi


fxTitle "⭐ Switching every version constraint to @stable..."
## bump-after-update would rewrite @stable to ^x.y.z on every update: keep it off
wsuSymfony composer config bump-after-update false --no-interaction
## Flex resolution filter: if left to x.y.*, it overrides the @stable constraints below
wsuSymfony composer config extra.symfony.require "@stable" --no-interaction

wsuSymfony composer require --no-update --no-interaction \
  'symfony/console:@stable' 'symfony/dotenv:@stable' 'symfony/flex:@stable' \
  'symfony/framework-bundle:@stable' 'symfony/runtime:@stable' 'symfony/yaml:@stable'


fxTitle "📦 composer req DEV-only"
wsuSymfony composer require --dev --no-update --no-interaction \
  'symfony/debug-bundle:@stable' 'symfony/stopwatch:@stable' 'symfony/web-profiler-bundle:@stable'


fxTitle "📦 composer update"
wsuSymfony composer update --no-interaction


fxTitle "Restoring PROJECT_DIR"
PROJECT_DIR=${PROJECT_DIR_BACKUP}
fxOK "PROJECT_DIR is now ##${PROJECT_DIR}##"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
rsync -a "${WSU_TMP_DIR}${APP_NAME}/" "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"


fxTitle "Adding .gitignore..."
## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore
curl -o "${PROJECT_DIR}.gitignore" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore

## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore_symfony
curl -o "${PROJECT_DIR}.gitignore_symfony_temp" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore_symfony
sed -i "s/my-app/${APP_NAME}/g" "${PROJECT_DIR}.gitignore_symfony_temp"
echo "" >> "${PROJECT_DIR}.gitignore"
cat "${PROJECT_DIR}.gitignore_symfony_temp" >> "${PROJECT_DIR}.gitignore"
rm -f "${PROJECT_DIR}.gitignore_symfony_temp"


fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"


cd "${CURRENT_DIR_BACKUP}"
