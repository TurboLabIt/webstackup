#!/usr/bin/env bash
echo ""
SCRIPT_NAME=webstackup

## bash-fx
if [ -z "$(command -v curl)" ]; then
  sudo apt update && sudo apt install curl -y
fi
curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/master/setup.sh?$(date +%s) | sudo bash
source /usr/local/turbolab.it/bash-fx/bash-fx.sh
## bash-fx is ready

sudo bash /usr/local/turbolab.it/bash-fx/setup/start.sh ${SCRIPT_NAME}

## Symlink (globally-available webstackup command)
if [ ! -f "/usr/local/bin/${SCRIPT_NAME}" ]; then
  ln -s ${INSTALL_DIR}script/${SCRIPT_NAME}.sh /usr/local/bin/${SCRIPT_NAME}
fi

sudo bash /usr/local/turbolab.it/bash-fx/setup/the-end.sh ${SCRIPT_NAME}
