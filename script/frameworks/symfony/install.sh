#!/usr/bin/env bash
### AUTOMATIC SYMFONY-CLI INSSTALLER BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/symfony/install.sh?$(date +%s) | sudo bash
#
# Source: https://symfony.com/download


## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "💿 Symfony-CLI installer "
rootCheck


fxTitle "Removing any old previous instance..."
apt purge --auto-remove symfony* -y
sudo rm -f /usr/local/bin/*symfony*


fxTitle "Installing pre-requisites..."
sudo apt update && sudo apt install ca-certificates apt-transport-https -y


fxTitle "Installing Symfony from cloudsmith.io..."
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
sudo apt install symfony-cli -y


fxEndFooter
