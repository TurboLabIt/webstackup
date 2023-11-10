#!/usr/bin/env bash
### AUTOMATIC WP-CLI INSSTALLER BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/wordpress/install.sh?$(date +%s) | sudo bash
#
# Source:


## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "💿 WordPress-CLI installer "
rootCheck


fxTitle "Removing any old previous instance..."
rm -f /usr/local/bin/wp-cli

curl -o /usr/local/bin/wp-cli https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod u=rwx,go=rx /usr/local/bin/wp-cli

fxEndFooter
