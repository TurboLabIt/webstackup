#!/usr/bin/env bash
### AUTOMATIC NODE.JS INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/node.js/install.sh
#
# Get the newest version of node here: https://github.com/nodesource/distributions/blob/master/README.md#debinstall
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/node.js/install.sh?$(date +%s) | sudo NODEJS_VER=19 bash
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

if [ -z "${NODEJS_VER}" ]; then
  fxCatastrophicError "NODEJS_VER is undefined! Cannot determine which version of Node.js to install"
fi


fxTitle "Removing any old previous instance of Node.js..."
apt purge --auto-remove nodejs* nvm* npm* -y


NODEJS_INSTALL_URL=https://deb.nodesource.com/setup_${NODEJS_VER}.x
fxTitle "Installing via sh from ${NODEJS_INSTALL_URL}..."
curl -s  "${NODEJS_INSTALL_URL}" | bash
apt update

## the NodeSource package contains both the node binary and npm
apt install -y nodejs


fxTitle "Current Node.js version..."
apt policy nodejs
node -v




fxEndFooter
