#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/script/php/test-runner-bundle.sh

clear
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
source <(curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php/symfony-bundle-builder.sh)
