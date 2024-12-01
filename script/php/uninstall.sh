#!/usr/bin/env bash
### AUTOMATIC PHP UNINSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/php/uninstall.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php/uninstall.sh?$(date +%s) | sudo PHP_VER=8.3 bash
#
# Based on: https://turbolab.it/1380

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "♻️ PHP uninstaller"
rootCheck

if [ -z "${PHP_VER}" ]; then
  fxCatastrophicError "PHP_VER is undefined! Cannot determine which version of PHP to uninstall"
fi


fxTitle "Removing any old previous instance of PHP ${PHP_VER} (if any)..."
fxInfo "Note: this will display some errors if PHP is not installed yet."
fxInfo "This is expected, don't freak out"
apt purge --auto-remove php${PHP_VER}* -y
rm -rf /etc/php/${PHP_VER} /var/log/php${PHP_VER}*


fxEndFooter
