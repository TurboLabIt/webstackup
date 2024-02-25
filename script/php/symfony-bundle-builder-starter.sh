#!/usr/bin/env bash
# 🪄 Based on XXXXXXX
# 📚 Usage guide: XXXXX

mkdir -p scripts
cd scripts
## https://github.com/TurboLabIt/webstackup/blob/master/script/php/symfony-bundle-builder.sh
if [ -f "/usr/local/turbolab.it/webstackup/script/php/symfony-bundle-builder.sh" ]; then
  source "/usr/local/turbolab.it/webstackup/script/php/symfony-bundle-builder.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php/symfony-bundle-builder.sh)
fi

