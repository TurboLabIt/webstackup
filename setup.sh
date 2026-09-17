#!/usr/bin/env bash
echo ""
SCRIPT_NAME=webstackup

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/master/setup.sh | sudo bash
source /usr/local/turbolab.it/bash-fx/bash-fx.sh
## bash-fx is ready

sudo bash /usr/local/turbolab.it/bash-fx/setup/start.sh ${SCRIPT_NAME}
fxLinkBin ${INSTALL_DIR}script/${SCRIPT_NAME}.sh
fxLinkBin ${INSTALL_DIR}script/mail/zzmail.sh
fxLinkBin ${INSTALL_DIR}script/mysql/zzdb.sh

if [ -f "/etc/mysql/mysql.conf.d/00-webstackup.cnf" ]; then

  sudo rm -f /etc/mysql/mysql.conf.d/00-webstackup.cnf
  sudo cp ${INSTALL_DIR}config/mysql/mysql.cnf /etc/mysql/mysql.conf.d/00-webstackup.cnf
  fxOK "MySQL config /etc/mysql/mysql.conf.d/00-webstackup.cnf updated"
fi

sudo bash /usr/local/turbolab.it/bash-fx/setup/the-end.sh ${SCRIPT_NAME}

if [ -f /usr/local/turbolab.it/zzalias/setup.sh ]; then
  sudo bash /usr/local/turbolab.it/zzalias/setup.sh
fi
