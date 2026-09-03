### Create a new React Router project automatically by WEBSTACKUP
## This script must be sourced! Example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/react-router-install.sh
##
## Based on: https://reactrouter.com/start/framework/installation

### Variables:
# APP_NAME
# PROJECT_DIR
#
# REACT_ROUTER_TEMPLATE (optional)
# REACT_ROUTER_VERSION  (optional)

fxHeader "🆕 React Router new"
rootCheck
expectedUserSetCheck

if [ -z "${APP_NAME}" ] || [ -z "${PROJECT_DIR}" ]; then

  fxCatastrophicError "React Router new can't run with these variables undefined:
  APP_NAME:                ##${APP_NAME}##
  PROJECT_DIR:             ##${PROJECT_DIR}##"
fi

CURRENT_DIR_BACKUP=$(pwd)
WSU_REACT_ROUTER_TEMPLATE_ARG=
WSU_REACT_ROUTER_VERSION_ARG=
WSU_REACT_ROUTER_SHADCN=


## asked upfront, so the (long) build below runs unattended
if [ -f "${PROJECT_DIR}package.json" ]; then

  fxWarning "##${PROJECT_DIR}package.json## already exists: this app looks installed already!"
  if ! fxAskYesNo "🔥 Overwrite it with a brand new React Router app?" N; then

    fxOK "Nothing done"
    return
  fi
fi

if fxAskYesNo "🤖 Do you want the React Router agent skill (for AI coding assistants)?"; then
  WSU_REACT_ROUTER_SKILLS_ARG="--agent-skills"
else
  WSU_REACT_ROUTER_SKILLS_ARG="--no-agent-skills"
fi

if fxAskYesNo "🎨 Do you want shadcn?"; then
  WSU_REACT_ROUTER_SHADCN=1
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
## create-react-router won't build into PROJECT_DIR: my-app-template is already in there
WSU_TMP_DIR=/tmp/wsu-react-router-new/
rm -rf "${WSU_TMP_DIR}"
mkdir -p "${WSU_TMP_DIR}"
chmod ugo=rwx "${WSU_TMP_DIR}" -R
cd "${WSU_TMP_DIR}"


if [ ! -z "${REACT_ROUTER_TEMPLATE}" ]; then

  WSU_REACT_ROUTER_TEMPLATE_ARG="--template ${REACT_ROUTER_TEMPLATE}"
  fxInfo "Template: ##${REACT_ROUTER_TEMPLATE}##"

else

  fxInfo "Template: ##default## (https://github.com/remix-run/react-router-templates/tree/main/default)"
fi

if [ ! -z "${REACT_ROUTER_VERSION}" ]; then

  WSU_REACT_ROUTER_VERSION_ARG="--react-router-version ${REACT_ROUTER_VERSION}"
  fxInfo "React Router: ##${REACT_ROUTER_VERSION}##"

else

  fxInfo "React Router: ##latest##"
fi


fxTitle "🆕 create-react-router..."
## https://reactrouter.com/start/framework/installation
## --no-install:  node_modules is installed further down, straight into PROJECT_DIR
## --no-git-init: the project comes with its own repo
sudo -u $EXPECTED_USER -H npx --yes create-react-router@latest "${APP_NAME}" \
  --yes --no-install --no-git-init --no-color --no-motion \
  ${WSU_REACT_ROUTER_SKILLS_ARG} ${WSU_REACT_ROUTER_TEMPLATE_ARG} ${WSU_REACT_ROUTER_VERSION_ARG}

WSU_REACT_ROUTER_BUILD_DIR=${WSU_TMP_DIR}${APP_NAME}/

if [ ! -f "${WSU_REACT_ROUTER_BUILD_DIR}package.json" ]; then
  fxCatastrophicError "create-react-router failed: ##${WSU_REACT_ROUTER_BUILD_DIR}package.json## not found"
fi


fxTitle "🐳 Dropping the Docker files (WEBSTACKUP runs node.js behind Nginx, not in a container)..."
rm -f "${WSU_REACT_ROUTER_BUILD_DIR}Dockerfile" "${WSU_REACT_ROUTER_BUILD_DIR}.dockerignore"


fxTitle "🚚 Moving the built directory to ##${PROJECT_DIR}##..."
## .gitignore is rebuilt below; README.md is the my-app-template one: don't let the React Router template win
rsync -a --exclude=".gitignore" --exclude="README.md" "${WSU_REACT_ROUTER_BUILD_DIR}" "${PROJECT_DIR}"
cd "${PROJECT_DIR}"
rm -rf "${WSU_TMP_DIR}"


fxTitle "Adding .gitignore..."
## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore
curl -o "${PROJECT_DIR}.gitignore" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore

## https://github.com/TurboLabIt/webdev-gitignore/blob/master/.gitignore_react-router
curl -o "${PROJECT_DIR}.gitignore_react-router_temp" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore_react-router
sed -i "s/my-app/${APP_NAME}/g" "${PROJECT_DIR}.gitignore_react-router_temp"
echo "" >> "${PROJECT_DIR}.gitignore"
cat "${PROJECT_DIR}.gitignore_react-router_temp" >> "${PROJECT_DIR}.gitignore"
rm -f "${PROJECT_DIR}.gitignore_react-router_temp"


## this runs *before* npm install on purpose: it would strip the exec bit off node_modules/.bin
fxSetWebPermissions "${EXPECTED_USER}" "${PROJECT_DIR}"


fxTitle "💿 npm install..."
cd "${PROJECT_DIR}"
echo "y" | sudo -u $EXPECTED_USER -H npm install


if [ "${WSU_REACT_ROUTER_SHADCN}" = 1 ]; then

  fxTitle "🎨 shadcn init..."
  ## https://ui.shadcn.com/docs/installation/react-router
  sudo -u $EXPECTED_USER -H npx --yes shadcn@latest init -t react-router -b base -p base-vega
fi


if grep -q '"typecheck":' "${PROJECT_DIR}package.json"; then

  fxTitle "🧪 npm run typecheck..."
  if ! sudo -u $EXPECTED_USER -H npm run typecheck; then
    fxWarning "typecheck failed! Fix it before running the app"
  fi
fi


fxTitle "🎉 The React Router app is ready"
fxMessage "dev:  cd ${PROJECT_DIR} && npm run dev -- --port ${NODE_PORT}"
fxMessage "prod: cd ${PROJECT_DIR} && npm run build && PORT=${NODE_PORT} npm start"
echo ""
fxInfo "☝ port ##${NODE_PORT}## must match \$proxy_pass_target in ##config/custom/nginx.conf##"

cd "${CURRENT_DIR_BACKUP}"
