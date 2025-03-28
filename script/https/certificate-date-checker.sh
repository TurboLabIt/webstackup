#!/usr/bin/env bash
### HTTPS CERTIFICATE EXPIRATION DATE CHECKER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/https/url-checker.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/certificate-date-checker.sh | bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🔐 HTTPS certificate expiration date checker"


fxTitle "URL to check"
while [ -z "$WSU_URL_HTTPS_EXPIRATION_CHECKER" ]; do

  echo "🤖 Provide the URL to check"
  read -p ">> " WSU_URL_HTTPS_EXPIRATION_CHECKER  < /dev/tty

done


fxTitle "🔍 Checking..."
curl "$WSU_URL_HTTPS_EXPIRATION_CHECKER" --head -v --stderr - | grep expir

fxEndFooter
