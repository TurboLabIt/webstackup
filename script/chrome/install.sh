#!/usr/bin/env bash
### AUTOMATIC CHROME INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/chrome/install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/chrome/install.sh | sudo bash
#
# Based on: https://turbolab.it/3267

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Chrome installer"
rootCheck

CHROME_FULLPATH=/usr/bin/google-chrome
CHROME_DEB_FULLPATH=/tmp/google-chrome-stable_current_amd64.deb


function chromeTestRun()
{
  fxTitle "🧪 Test run..."
  fxMessage "${CHROME_FULLPATH} --headless --no-sandbox --dump-dom 'https://turbolabit.github.io/html-pages/fetchable.html'"
  echo ""

  "${CHROME_FULLPATH}" --headless --no-sandbox --dump-dom 'https://turbolabit.github.io/html-pages/fetchable.html'
  rm -rf "/tmp/Crashpad"

  fxOK "Chrome is ready!"
  fxInfo "📣 You can also use it headlessly with https://github.com/TurboLabIt/php-chrome-headless"
  fxInfo "📣 To generate PDFs: https://github.com/TurboLabIt/webstackup/blob/master/script/print/install-pdf.sh"
}


if [ -f "${CHROME_FULLPATH}" ]; then

  fxImportantMessage "Chrome is already installed"
  chromeTestRun
  fxEndFooter
  exit
fi


fxTitle "⬇️ Downloading Chrome..."
curl -Lo "${CHROME_DEB_FULLPATH}" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb


fxTitle "💿 Installing Chrome..."
fxAptUpdate
## the .deb pulls its own dependencies in, so it must be installed by apt, not by dpkg
apt install "${CHROME_DEB_FULLPATH}" -y
rm -f "${CHROME_DEB_FULLPATH}"

if [ ! -f "${CHROME_FULLPATH}" ]; then
  fxCatastrophicError "Chrome was not installed (apt failure?)"
fi


fxTitle "📂 Preparing the www-data home..."
if [ ! -d "/var/www" ]; then

  fxInfo "Skipped (/var/www not found) 🦘"

else

  mkdir -p "/var/www/.local"
  chown www-data:www-data "/var/www/.local" -R
  chmod ug=rwx,o=rx "/var/www/.local" -R
  fxOK "/var/www/.local is ready"
fi


chromeTestRun

fxEndFooter
