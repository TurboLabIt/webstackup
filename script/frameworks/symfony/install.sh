#!/usr/bin/env bash
### Automatic symfony-cli install by WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/symfony/install.sh?$(date +%s) | sudo bash
#

## https://symfony.com/download
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
sudo apt install symfony-cli -y
