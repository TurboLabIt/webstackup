### Create a new Strapi project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/strapi-install.sh
##
## Based on: https://docs.strapi.io/cms/installation/cli

### Variables:
# APP_NAME
# PROJECT_DIR
#
# STRAPI_TEMPLATE   (optional)
# STRAPI_PUBLIC_URL (optional)
# STRAPI_ADMIN_NEW_SLUG (optional: the admin panel path, "admin" when empty)
# STRAPI_ADMIN_EMAIL (optional: the first administrator, skipped when empty; the name is the part before @)
# MYSQL_USER, MYSQL_PASSWORD, MYSQL_HOST, MYSQL_DB_NAME (optional: SQLite when MYSQL_DB_NAME is empty)

fxHeader "🆕 Strapi new"
rootCheck
expectedUserSetCheck

if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ]; then

  fxCatastrophicError "Strapi new can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  PROJECT_DIR:             ##${PROJECT_DIR}##"
fi

CURRENT_DIR_BACKUP=$(pwd)
WSU_STRAPI_ARGS=()


## asked upfront, so the (long) build below runs unattended
if [ -f "${PROJECT_DIR}package.json" ]; then

  fxWarning "##${PROJECT_DIR}package.json## already exists: this app looks installed already!"
  if ! fxAskYesNo "🔥 Overwrite it with a brand new Strapi app?" N; then

    fxOK "Nothing done"
    return
  fi
fi

if [ ! -z "${STRAPI_TEMPLATE}" ]; then

  ## create-strapi rejects --typescript and --no-example together with --template: the template decides
  WSU_STRAPI_ARGS+=(--template "${STRAPI_TEMPLATE}")

else

  ## TypeScript, no example structure & data: no questions asked
  WSU_STRAPI_ARGS+=(--typescript --no-example)
fi


fxTitle "🗄️ Database..."
if [ ! -z "${MYSQL_DB_NAME}" ] && [ ! -z "${MYSQL_USER}" ]; then

  ## Node.js resolves "localhost" via DNS (::1 first) while MySQL listens on 127.0.0.1 only
  WSU_STRAPI_DB_HOST=${MYSQL_HOST}
  if [ "${WSU_STRAPI_DB_HOST}" = "localhost" ]; then
    WSU_STRAPI_DB_HOST=127.0.0.1
  fi

  ## create-strapi wants all six --db* args together
  WSU_STRAPI_ARGS+=(--dbclient mysql --dbhost "${WSU_STRAPI_DB_HOST}" --dbport 3306 --dbname "${MYSQL_DB_NAME}" --dbusername "${MYSQL_USER}" --dbpassword "${MYSQL_PASSWORD}")
  fxOK "MySQL: ##${MYSQL_USER}@${WSU_STRAPI_DB_HOST}/${MYSQL_DB_NAME}##"

else

  ## the my-app-template wizard stores the credentials in /etc/turbolab.it/mysql-${APP_NAME}.conf, sourced by strapi-install.sh
  WSU_STRAPI_ARGS+=(--skip-db)
  fxWarning "No MySQL credentials (MYSQL_DB_NAME is empty): using SQLite (.tmp/data.db), OK for dev only!"
fi


fxTitle "🤹 Checking node.js..."
if [ -z "$(command -v npm)" ]; then

  fxInfo "npm not found. Installing node.js now..."
  ## https://github.com/TurboLabIt/webstackup/blob/master/script/node.js/install.sh
  sudo bash "${WEBSTACKUP_SCRIPT_DIR}node.js/install.sh"
  hash -r

else
  fxOK
fi

## https://github.com/TurboLabIt/webstackup/blob/master/script/node.js/node_script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}node.js/node_script_begin.sh"


fxTitle "Setting up temp directory..."
## create-strapi won't build into PROJECT_DIR: my-app-template is already in there
WSU_TMP_DIR=/tmp/wsu-strapi-new/
rm -rf "${WSU_TMP_DIR}"
mkdir -p "${WSU_TMP_DIR}"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WSU_TMP_DIR}"


fxInfo "Strapi: ##latest stable## (create-strapi@latest)"

if [ ! -z "${STRAPI_TEMPLATE}" ]; then

  fxInfo "Template: ##${STRAPI_TEMPLATE}##"

else

  fxInfo "Template: ##default## (https://github.com/strapi/strapi/tree/develop/packages/cli/create-strapi-app/templates)"
fi


fxTitle "🆕 create-strapi..."
## https://docs.strapi.io/cms/installation/cli
## --non-interactive: every choice is passed as a flag, nothing may prompt (--skip-cloud: no Strapi Cloud login either)
## --no-install:      node_modules is installed further down, straight into PROJECT_DIR
## --no-git-init:     the project comes with its own repo
sudo -u $EXPECTED_USER -H npx --yes create-strapi@latest "${APP_NAME}" \
  --non-interactive --skip-cloud --no-run --use-npm --no-install --no-git-init \
  "${WSU_STRAPI_ARGS[@]}"

WSU_STRAPI_BUILD_DIR=${WSU_TMP_DIR}${APP_NAME}/

if [ ! -f "${WSU_STRAPI_BUILD_DIR}package.json" ]; then
  fxCatastrophicError "create-strapi failed: ##${WSU_STRAPI_BUILD_DIR}package.json## not found"
fi


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
## .gitignore is rebuilt below; README.md is the my-app-template one: don't let the Strapi template win
rsync -a --exclude=".gitignore" --exclude="README.md" "${WSU_STRAPI_BUILD_DIR}" "${PROJECT_DIR}"
cd "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"


fxTitle "Adding .gitignore..."
## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore
curl -o "${PROJECT_DIR}.gitignore" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore

## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore_strapi
curl -o "${PROJECT_DIR}.gitignore_strapi_temp" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore_strapi
sed -i "s/my-app/${APP_NAME}/g" "${PROJECT_DIR}.gitignore_strapi_temp"
echo "" >> "${PROJECT_DIR}.gitignore"
cat "${PROJECT_DIR}.gitignore_strapi_temp" >> "${PROJECT_DIR}.gitignore"
rm -f "${PROJECT_DIR}.gitignore_strapi_temp"


fxTitle "🌐 Nginx reverse proxy support in config/server..."
## https://docs.strapi.io/cms/configurations/server
## url:   the public URL of this env (PUBLIC_URL in .env): reset-password links, absolute media URLs, ...
## proxy: trust the X-Forwarded-* headers set by Nginx (HTTPS detection, real client IP)
WSU_STRAPI_SERVER_CONFIG=$(ls "${PROJECT_DIR}config/server.ts" "${PROJECT_DIR}config/server.js" 2> /dev/null | head -n 1)

if [ -z "${WSU_STRAPI_SERVER_CONFIG}" ]; then

  fxWarning "config/server.ts|js not found: set ##url## and ##proxy## yourself"

elif grep -q "proxy:" "${WSU_STRAPI_SERVER_CONFIG}"; then

  fxInfo "##proxy## is already there, skipping 🦘"

elif grep -qF "  port: env.int('PORT', 1337)," "${WSU_STRAPI_SERVER_CONFIG}"; then

  sed -i "/^  port: env.int('PORT', 1337),$/a\  \/\/ 🪄 Added by WEBSTACKUP for Nginx: PUBLIC_URL lives in .env, proxy trusts the X-Forwarded-* headers\n  url: env('PUBLIC_URL', ''),\n  proxy: { koa: env.bool('IS_PROXIED', true) }," "${WSU_STRAPI_SERVER_CONFIG}"
  fxOK "##url## and ##proxy## added to ##${WSU_STRAPI_SERVER_CONFIG}##"
  cat "${WSU_STRAPI_SERVER_CONFIG}"

else

  fxWarning "##${WSU_STRAPI_SERVER_CONFIG}## looks custom: set ##url## and ##proxy## yourself"
fi


WSU_STRAPI_ADMIN_PATH=admin
if [ ! -z "${STRAPI_ADMIN_NEW_SLUG}" ]; then

  fxTitle "🕵️ Admin panel path: /${STRAPI_ADMIN_NEW_SLUG#/} instead of /admin..."
  ## https://docs.strapi.io/cms/configurations/admin-panel
  ## url: where the admin panel is served | auth.cookie.path: must match url. Both are inlined into the admin bundle at build time
  WSU_STRAPI_ADMIN_PATH=${STRAPI_ADMIN_NEW_SLUG#/}
  WSU_STRAPI_ADMIN_CONFIG=$(ls "${PROJECT_DIR}config/admin.ts" "${PROJECT_DIR}config/admin.js" 2> /dev/null | head -n 1)

  if [[ ! "${WSU_STRAPI_ADMIN_PATH}" =~ ^[A-Za-z0-9_-]+$ ]]; then

    fxWarning "##${WSU_STRAPI_ADMIN_PATH}## is not a valid slug ([A-Za-z0-9_-] only): keeping /admin"
    WSU_STRAPI_ADMIN_PATH=admin

  elif [ -z "${WSU_STRAPI_ADMIN_CONFIG}" ]; then

    fxWarning "config/admin.ts|js not found: set ##url## and ##auth.cookie.path## yourself"
    WSU_STRAPI_ADMIN_PATH=admin

  elif grep -q "url:" "${WSU_STRAPI_ADMIN_CONFIG}"; then

    fxWarning "##url## is already set in ##${WSU_STRAPI_ADMIN_CONFIG}##: leaving it alone"
    WSU_STRAPI_ADMIN_PATH=admin

  elif grep -qE "^    secret: env\('ADMIN_JWT_SECRET'\)!?,$" "${WSU_STRAPI_ADMIN_CONFIG}"; then

    ## the first line ending with "=> ({" opens the config object (the TS and JS templates differ before that)
    sed -i "0,/=> ({$/s|=> ({$|=> ({\n  // 🪄 Added by WEBSTACKUP: the admin panel is served here instead of /admin (rebuild it after changing this)\n  url: '/${WSU_STRAPI_ADMIN_PATH}',|" "${WSU_STRAPI_ADMIN_CONFIG}"
    sed -i -E "/^    secret: env\('ADMIN_JWT_SECRET'\)!?,$/a\    cookie: {\n      path: '/${WSU_STRAPI_ADMIN_PATH}', // must match url\n    }," "${WSU_STRAPI_ADMIN_CONFIG}"
    fxOK "##url## and ##auth.cookie.path## set to ##/${WSU_STRAPI_ADMIN_PATH}## in ##${WSU_STRAPI_ADMIN_CONFIG}##"
    cat "${WSU_STRAPI_ADMIN_CONFIG}"

  else

    fxWarning "##${WSU_STRAPI_ADMIN_CONFIG}## looks custom: set ##url## and ##auth.cookie.path## yourself"
    WSU_STRAPI_ADMIN_PATH=admin
  fi
fi


fxTitle "📝 Stamping the admin path into README.md..."
## the my-app-template README links the admin panel at /secret-admin-slug
if [ -f "${PROJECT_DIR}README.md" ]; then
  fxReplaceContentInFile "${PROJECT_DIR}README.md" "secret-admin-slug" "${WSU_STRAPI_ADMIN_PATH}"
else
  fxInfo "No README.md, skipping 🦘"
fi


fxTitle "🌳 .env..."
## generated by create-strapi with fresh secrets. NOT versioned: on staging|prod, recreate it from .env.example
## HOST: Nginx is the only client | PORT: must match config/custom/nginx.conf | PUBLIC_URL: https://... of this env
fxDotEnvSet "${PROJECT_DIR}.env" HOST 127.0.0.1
fxDotEnvSet "${PROJECT_DIR}.env" PORT "${NODE_PORT}"

## PUBLIC_URL is a WEBSTACKUP addition (read by config/server): it belongs with the other "# Server" settings, not at the end of the file
if ! grep -q "^PUBLIC_URL=" "${PROJECT_DIR}.env"; then
  sed -i "/^PORT=/a PUBLIC_URL=" "${PROJECT_DIR}.env"
fi
fxDotEnvSet "${PROJECT_DIR}.env" PUBLIC_URL "${STRAPI_PUBLIC_URL}"

if [ -z "${STRAPI_TEMPLATE}" ]; then

  fxTitle "📝 .env.example..."
  ## the real .env with the secrets blanked: the recipe for the staging|prod .env (the stock one lacks the DATABASE_* keys)
  sed -E 's/^(APP_KEYS|API_TOKEN_SALT|ADMIN_JWT_SECRET|JWT_SECRET|TRANSFER_TOKEN_SALT|ENCRYPTION_KEY|DATABASE_PASSWORD)=.*/\1=tobemodified/' "${PROJECT_DIR}.env" > "${PROJECT_DIR}.env.example"
  cat "${PROJECT_DIR}.env.example"
fi


## this runs *before* npm install on purpose: it would strip the exec bit off node_modules/.bin
fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"

## secrets and the DB password: not for "others" (fxSetWebPermissions gives go=r to every file)
chmod u=rw,g=r,o= "${PROJECT_DIR}.env"


fxTitle "💿 npm install..."
cd "${PROJECT_DIR}"
echo "y" | sudo -u $EXPECTED_USER -H npm install


fxTitle "🏗️ npm run build (admin panel)..."
## slow, but the best check that everything (config/server included) is fine. scripts/run.sh rebuilds anyway
if ! sudo -u $EXPECTED_USER -H npm run build; then
  fxWarning "Build failed! Fix it before running the app"
fi


WSU_STRAPI_ADMIN_PASSWORD=
if [ ! -z "${STRAPI_ADMIN_EMAIL}" ]; then

  fxTitle "👤 Creating the first administrator ##${STRAPI_ADMIN_EMAIL}##..."
  ## https://docs.strapi.io/cms/cli#strapi-admincreate-user
  ## --firstname is mandatory (--lastname is not): the part of the email before @ will do
  ## fxPasswordGenerator satisfies the Strapi policy (8+ chars with a number, an uppercase and a lowercase letter)
  WSU_STRAPI_ADMIN_PASSWORD=$(fxPasswordGenerator)

  if ! sudo -u $EXPECTED_USER -H NODE_ENV=$NODE_ENV npm run strapi -- admin:create-user --firstname="${STRAPI_ADMIN_EMAIL%%@*}" --email="${STRAPI_ADMIN_EMAIL}" --password="${WSU_STRAPI_ADMIN_PASSWORD}"; then

    fxWarning "Administrator creation failed! Register the first one at /${WSU_STRAPI_ADMIN_PATH} instead"
    WSU_STRAPI_ADMIN_PASSWORD=
  fi

else

  fxInfo "No STRAPI_ADMIN_EMAIL: register the first administrator at /${WSU_STRAPI_ADMIN_PATH}"
fi


fxTitle "🎉 The Strapi app is ready"
fxMessage "dev:  ${PROJECT_DIR}scripts/watch.sh    👉 npm run develop (auto-reload + admin panel hot reload)"
fxMessage "prod: ${PROJECT_DIR}scripts/run.sh      👉 npm run build && npm run start"
fxMessage "cli:  ${PROJECT_DIR}scripts/cli.sh ...  👉 npm run strapi -- ... (https://docs.strapi.io/cms/cli)"
echo ""
fxInfo "☝ port ##${NODE_PORT}## (PORT in .env) must match \$proxy_pass_target in ##config/custom/nginx.conf##"
if [ ! -z "${WSU_STRAPI_ADMIN_PASSWORD}" ]; then

  echo ""
  fxMessage "Your admin email is:    ${STRAPI_ADMIN_EMAIL}"
  fxMessage "Your admin password is: ${WSU_STRAPI_ADMIN_PASSWORD}"
  echo ""
  echo "Please login at ${STRAPI_PUBLIC_URL%/}/${WSU_STRAPI_ADMIN_PATH}"

else

  fxInfo "👤 Open ##/${WSU_STRAPI_ADMIN_PATH}## to register the first administrator"
fi
fxInfo "🌳 ##.env## is not versioned (secrets!): on staging|prod, create it from ##.env.example##"

cd "${CURRENT_DIR_BACKUP}"
