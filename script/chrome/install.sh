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

chromeTestRun()
{
  echo -e "\e[1;36m /usr/bin/google-chrome --headless --no-sandbox --dump-dom 'https://turbolabit.github.io/html-pages/fetchable.html' \e[0m"
  echo ""
  
  /usr/bin/google-chrome --headless --no-sandbox --dump-dom 'https://turbolabit.github.io/html-pages/fetchable.html'
  rm -rf "/tmp/Crashpad"
  
  echo -e "\e[1;32m ✔ Chrome is ready! \e[0m"
  echo -e "\e[1;32m 📣 You can also use it headlessly with https://github.com/TurboLabIt/php-chrome-headless \e[0m"
  echo -e "\e[1;32m 📣 To generate PDFs: https://github.com/TurboLabIt/webstackup/blob/master/script/print/install-pdf.sh \e[0m"
}

if [ -f "/usr/bin/google-chrome" ]; then
  echo -e "\e[1;33m Chrome is already installed \e[0m"
  chromeTestRun
  exit
fi

echo -e "\e[1;33m Installing Chrome... \e[0m"

## https://turbolab.it/3267
wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt update
apt install ./chrome.deb -y
rm -f chrome.deb

if [ -d "/var/www" ]; then
  mkdir -p "/var/www/.local"
  chown www-data:www-data "/var/www/.local" -R
  chmod ug=rwx,o=rx "/var/www/.local"  -R
fi

chromeTestRun
