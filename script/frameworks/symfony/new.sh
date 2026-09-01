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


## asked upfront, so the (long) build below runs unattended
if fxAskYesNo "🌿 Do you want Twig?"; then
  WSU_SYMFONY_OPTIONAL_PACKAGES="symfony/twig-pack:@stable symfony/asset:@stable"
fi

if fxAskYesNo "🗃️ Do you want Doctrine?"; then
  WSU_SYMFONY_DOCTRINE=1
  WSU_SYMFONY_OPTIONAL_PACKAGES="${WSU_SYMFONY_OPTIONAL_PACKAGES} symfony/orm-pack:@stable stof/doctrine-extensions-bundle:@stable turbolabit/service-entity-plus-bundle:dev-main"
fi

if fxAskYesNo "📧 Do you need to send emails?"; then
  WSU_SYMFONY_OPTIONAL_PACKAGES="${WSU_SYMFONY_OPTIONAL_PACKAGES} symfony/mailer:@stable"
fi

if fxAskYesNo "📢 Do you need to send messages to Telegram, Slack or social networks?"; then
  WSU_SYMFONY_OPTIONAL_PACKAGES="${WSU_SYMFONY_OPTIONAL_PACKAGES} turbolabit/php-symfony-messenger:dev-main"
fi

if fxAskYesNo "⌨️ Do you need to build CLI commands?"; then
  WSU_SYMFONY_BASECOMMAND=1
  WSU_SYMFONY_OPTIONAL_PACKAGES="${WSU_SYMFONY_OPTIONAL_PACKAGES} turbolabit/php-symfony-basecommand:dev-main"
fi

if fxAskYesNo "🧪 You are going to add tests, right?"; then
  WSU_SYMFONY_OPTIONAL_DEV_PACKAGES="phpunit:@stable brianium/paratest:@stable"
fi


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
  'symfony/framework-bundle:@stable' 'symfony/runtime:@stable' 'symfony/yaml:@stable' \
  ${WSU_SYMFONY_OPTIONAL_PACKAGES}


fxTitle "📦 composer req DEV-only"
wsuSymfony composer require --dev --no-update --no-interaction \
  'symfony/debug-bundle:@stable' 'symfony/stopwatch:@stable' 'symfony/web-profiler-bundle:@stable' \
  'symfony/maker-bundle:@stable' 'symfony/debug-pack:@stable' \
  ${WSU_SYMFONY_OPTIONAL_DEV_PACKAGES}


fxTitle "📦 composer update"
wsuSymfony composer update --no-interaction


## Flex always unpacks the *-pack metapackages, writing THEIR constraints
## (i.e. twig/twig "^2.12|^3.0") into composer.json: bring those back to @stable
fxTitle "⭐ Re-applying @stable to the constraints unpacked by the packs..."
WSU_STABLEIZE_PHP='
$json = json_decode(file_get_contents($argv[2]), true);
$packages = [];
foreach (($json[$argv[1]] ?? []) as $package => $constraint) {

  if ($constraint === "@stable" || $package === "php" ||
      str_starts_with($package, "ext-") || str_starts_with($constraint, "dev-")) {
    continue;
  }

  $packages[] = $package . ":@stable";
}
echo implode(" ", $packages);
'

WSU_UNPACKED=$(${PHP_CLI} -r "${WSU_STABLEIZE_PHP}" -- require "${PROJECT_DIR}composer.json")
WSU_UNPACKED_DEV=$(${PHP_CLI} -r "${WSU_STABLEIZE_PHP}" -- require-dev "${PROJECT_DIR}composer.json")

if [ ! -z "${WSU_UNPACKED}" ]; then
  fxInfo "require: ##${WSU_UNPACKED}##"
  wsuSymfony composer require --no-update --no-interaction ${WSU_UNPACKED}
fi

if [ ! -z "${WSU_UNPACKED_DEV}" ]; then
  fxInfo "require-dev: ##${WSU_UNPACKED_DEV}##"
  wsuSymfony composer require --dev --no-update --no-interaction ${WSU_UNPACKED_DEV}
fi

if [ ! -z "${WSU_UNPACKED}" ] || [ ! -z "${WSU_UNPACKED_DEV}" ]; then
  wsuSymfony composer update --no-interaction
else
  fxOK "Nothing to do"
fi


if [ ! -z "${WSU_SYMFONY_DOCTRINE}" ]; then

  fxTitle "Setting up doctrine-extensions..."
  echo "stof_doctrine_extensions:
  orm:
    default:
      timestampable: true
" > "${PROJECT_DIR}config/packages/stof_doctrine_extensions.yaml"

  wsuSymfony console lint:yaml config/packages/stof_doctrine_extensions.yaml
  wsuSymfony console debug:config stof_doctrine_extensions > /dev/null
  fxOK "timestampable enabled"
fi


if [ ! -z "${WSU_SYMFONY_BASECOMMAND}" ]; then

  fxTitle "⌨️ Adding the example command..."
  mkdir -p "${PROJECT_DIR}src/Command"
  ## https://github.com/TurboLabIt/php-symfony-basecommand/blob/main/docs/ExampleCommand.php
  curl -L -o "${PROJECT_DIR}src/Command/ExampleCommand.php" \
    https://raw.githubusercontent.com/TurboLabIt/php-symfony-basecommand/refs/heads/main/docs/ExampleCommand.php

  if ! ${PHP_CLI} -l "${PROJECT_DIR}src/Command/ExampleCommand.php" > /dev/null; then
    fxWarning "##src/Command/ExampleCommand.php## doesn't parse: fix it before running bin/console"
  fi
fi


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
