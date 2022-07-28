#!/usr/bin/env bash
### Automatic symfony-cli install by WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/symfony/install.sh?$(date +%s) | sudo bash
#

echo ""
echo -e "\e[1;46m ================== \e[0m"
echo -e "\e[1;46m 📐 SYMFONY INSTALL \e[0m"
echo -e "\e[1;46m ================== \e[0m"

SYMFONY_FILE_PATH=/usr/local/bin/symfony
sudo rm -f "${SYMFONY_FILE_PATH}"

## https://symfony.com/download
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
sudo apt install symfony-cli -y
