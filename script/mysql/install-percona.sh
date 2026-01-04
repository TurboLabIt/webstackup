#!/usr/bin/env bash
### AUTOMATIC PERCONA INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/install-percona.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/install-percona.sh | sudo MYSQL_VER=8.4 bash
#
# 📚 https://docs.percona.com/percona-server/8.4/quickstart-apt.html

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Percona installer"
rootCheck

fxTitle "Removing any old previous instance..."
apt purge --auto-remove mysql* -y
rm -rf /etc/mysql

fxTitle "Installing..."
apt update -qq
sudo apt update && sudo apt install curl gnupg2 lsb-release -y && \
  curl -Lo /tmp/percona-release_latest.generic_all.deb https://repo.percona.com/apt/percona-release_latest.generic_all.deb && \
  sudo apt install /tmp/percona-release_latest.generic_all.deb -y && \
  sudo apt update && sudo percona-release setup ps-84-lts && sudo percona-release enable ps-84-lts release && \
  sudo apt update && sudo apt install percona-server-server -y


fxTitle "Restarting MySQL"
service mysql restart
systemctl --no-pager status mysql

fxEndFooter
