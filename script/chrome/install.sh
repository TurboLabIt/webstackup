#!/usr/bin/env bash
### AUTOMATIC Chrome Headless INSTALL BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/chrome/install.sh?$(date +%s) | sudo bash
# 

echo ""
if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi

## https://turbolab.it/chrome-144/come-installare-chrome-stabile-beta-dev-ubuntu-modo-giusto-sola-riga-comando-video-3267
wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt update
apt install ./chrome.deb -y
rm -f chrome.deb

