#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/symfony-bundle-builder.sh
# 📚 Usage guide: https://github.com/TurboLabIt/webstackup/blob/master/script/php/symfony-bundle-builder.sh

clear
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
## https://github.com/TurboLabIt/webstackup/blob/master/script/php/symfony-bundle-builder.sh
source <(curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php/symfony-bundle-builder.sh)