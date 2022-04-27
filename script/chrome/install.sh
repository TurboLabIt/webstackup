#!/usr/bin/env bash
### AUTOMATIC Chrome INSTALL BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/chrome/install.sh?$(date +%s) | sudo bash
# 

echo ""
echo -e "\e[1;46m ================= \e[0m"
echo -e "\e[1;46m INSTALLING CHROME \e[0m"
echo -e "\e[1;46m ================= \e[0m"

if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi

CHROME_TEST_CMD="/usr/bin/google-chrome --headless --no-sandbox --dump-dom 'https://turbolabit.github.io/html-pages/fetchable.html'"

if [ -f "/usr/bin/google-chrome" ]; then
  echo -e "\e[1;33m ✔ Chome is already installed \e[0m"
  $CHROME_TEST_CMD
  exit
fi

## https://turbolab.it/3267
wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt update
apt install ./chrome.deb -y
rm -f chrome.deb

$CHROME_TEST_CMD

echo -e "\e[1;32m Chrome is ready! \e[0m"
echo -e "\e[1;32m 📣 You can also use it headlessly with https://github.com/TurboLabIt/php-chrome-headless \e[0m"
