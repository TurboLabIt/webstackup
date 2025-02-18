#!/usr/bin/env bash
### AUTOMATIC COMPOSER INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/php/composer-install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php/composer-install.sh | sudo bash
#
# Based on: https://getcomposer.org/download/

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Composer installer"
rootCheck


fxTitle "Downloading..."
COMPOSER_EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
COMPOSER_ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

fxTitle "Checking signature..."
if [ "$COMPOSER_EXPECTED_SIGNATURE" != "$COMPOSER_ACTUAL_SIGNATURE" ]; then

  catastrophicError "Composer signature doesn't match! Abort! Abort!"

  Expec. hash: ### ${COMPOSER_EXPECTED_SIGNATURE}
  Actual hash: ### ${COMPOSER_ACTUAL_SIGNATURE}"
  
fi

fxOK "Signature OK"


fxTitle "Installing..."
php composer-setup.php --filename=composer --install-dir=/usr/local/bin
php -r "unlink('composer-setup.php');"


fxEndFooter
