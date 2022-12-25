#!/usr/bin/env bash
### AUTOMATIC NODE.JS INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/node.js/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/node.js/install.sh?$(date +%s) | sudo NODEJS_VER=19 bash
#
# Based on: https://turbolab.it/

## https://github.com/nodesource/distributions/blob/master/README.md#debinstall
NODEJS_LATEST_VERSION=19

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Node.js installer"
rootCheck


fxTitle "Removing any old previous instance of Node.js..."
if [ ! -z "$(command -v n)" ]; then
  n prune
  echo "y" | n uninstall
fi

apt purge --auto-remove nodejs* npm* -y
rm -f /etc/apt/sources.list.d/nodesource*
apt update
rm -rf /usr/bin/node
rm -rf /usr/local/bin/node
rm -rf /usr/lib/node_modules
rm -rf /usr/local/lib/node_modules
rm -rf /usr/local/n/
rm -rf "$(getent passwd $SUDO_USER | cut -d: -f6)/.nvm"


NODEJS_INSTALL_URL=https://deb.nodesource.com/setup_${NODEJS_LATEST_VERSION}.x
fxTitle "Running ${NODEJS_INSTALL_URL}..."
fxInfo "Don't freak out if this is not the version you requested!"
fxInfo "The version you requested will be installed later on"
curl -s  "${NODEJS_INSTALL_URL}" | bash


fxTitle "Installing..."
## the NodeSource package contains both the node binary and npm
apt install -y nodejs


fxTitle "Current Node.js version..."
apt policy nodejs
node --version


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
