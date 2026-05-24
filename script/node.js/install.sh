#!/usr/bin/env bash
### AUTOMATIC NODE.JS INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/node.js/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/node.js/install.sh | sudo NODEJS_VER=24 bash
#
# Based on: https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions

## https://github.com/nodesource/distributions/blob/master/README.md#debinstall
NODEJS_LATEST_VERSION=24

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Node.js installer"
rootCheck

if [ -z "$NODEJS_VER" ]; then
  NODEJS_VER=$NODEJS_LATEST_VERSION
fi


fxTitle "Removing any old previous instance of Node.js..."
if [ ! -z "$(command -v n)" ]; then
  n prune
  echo "y" | n uninstall
fi

apt purge --auto-remove nodejs* npm* -y
apt update
rm -rf /usr/bin/node
rm -rf /usr/local/bin/node
rm -rf /usr/lib/node_modules
rm -rf /usr/local/lib/node_modules
rm -rf /usr/local/n/
rm -rf "$(getent passwd $SUDO_USER | cut -d: -f6)/.nvm"


fxTitle "🔑 Downloading the Nodesource GPG key..."
apt update
apt install ca-certificates curl gnupg -y
mkdir -p /etc/apt/keyrings
rm -rf /etc/apt/keyrings/*nodesource*
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg


fxTitle "🔗 Creating the deb repository..."
rm -f /etc/apt/sources.list.d/*nodesource*
cat <<EOF | sudo tee /etc/apt/sources.list.d/webstackup-nodesource.sources
Types: deb
URIs: https://deb.nodesource.com/node_$NODEJS_LATEST_VERSION.x
Suites: nodistro
Components: main
Signed-By: /etc/apt/keyrings/nodesource.gpg
EOF

ls -la /etc/apt/sources.list.d/


fxTitle "💿 Installing Node.js..."
apt update
## the NodeSource package contains both the node binary and npm
apt install nodejs -y


fxTitle "Current Node.js version..."
apt policy nodejs
node --version
fxInfo "Don't freak out if this is not the version you requested!"
fxInfo "The version you requested will be installed later on"


fxTitle "Enabling corepack..."
corepack enable


fxTitle "Installing yarn via corepack..."
## https://yarnpkg.com/getting-started/install
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

corepack prepare yarn@stable --activate
yarn install


fxTitle "Current yarn version..."
yarn --version


fxTitle "Installing the n package..."
## https://github.com/tj/n#installation
npm install -g n
n --version


fxTitle "Installing the requested version..."
if [ -z "${NODEJS_VER}" ]; then

  fxInfo "No specific version of Node.js requested"
  n ${NODEJS_LATEST_VERSION}
  
else
  
  fxInfo "Installing your requested version ##${NODEJS_VER}##"
  n ${NODEJS_VER}
fi


fxTitle "Current Node.js version..."
hash -r 
node --version

if [ ! -z "${NODEJS_VER}" ]; then
  fxInfo "☝ this should be the version ##${NODEJS_VER}## you requested"
fi


fxTitle "📃 To install additional version(s)..."
echo "To list the available versions:"
fxMessage "n ls-remote --all"
echo "To install/use another version(s)"
fxMessage "sudo n 10.15.0 && node --version"
fxInfo "☝ put this at the top of your deploy script"


fxEndFooter
