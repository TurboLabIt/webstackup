#!/usr/bin/env bash
### AUTOMATIC NODE.JS INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/node.js/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/node.js/install.sh?$(date +%s) | sudo NODEJS_VER=19.3.0 bash
#
# Based on: https://turbolab.it/

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
apt purge --auto-remove nodejs* npm* -y
rm -f /etc/apt/sources.list.d/nodesource*
apt update
rm -f /usr/bin/node
rm -f /usr/local/bin/node


NODEJS_INSTALL_URL=https://deb.nodesource.com/setup_19.x
fxTitle "Running ${NODEJS_INSTALL_URL}..."
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


fxTitle "Current n version..."
n --version


fxTitle "Listing available Node.js version"
n ls-remote --all


fxTitle "Installing the requested version..."
if [ -z "${NODEJS_VER}" ]; then
  fxInfo "No specific version of Node.js requested"
else
  n ${NODEJS_VER}
fi


fxTitle "Current Node.js version..."
hash -r 
node --version


fxTitle "📃 To install other versions..."
echo "To list all the available versions: n ls-remote --all"
echo "To install/use another version: sudo n 10.15.0 && hash -r"


fxEndFooter
