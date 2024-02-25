#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/symfony-bundle-builder/scripts/symfony-bundle-tester.sh
# 📚 Usage guide: https://github.com/TurboLabIt/webstackup/blob/master/script/php/symfony-bundle-builder.sh

clear
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

## https://github.com/TurboLabIt/webstackup/blob/master/script/php/symfony-bundle-tester.sh
if [ -f "/usr/local/turbolab.it/webstackup/script/php/symfony-bundle-tester.sh" ]; then
  source "/usr/local/turbolab.it/webstackup/script/php/symfony-bundle-tester.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php/symfony-bundle-tester.sh)
fi

