#!/usr/bin/env bash
### BENTOPDF RUNNER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/bentopdf/run.sh
clear

## https://github.com/TurboLabIt/bash-fx
if [ -z "$(command -v curl)" ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📃 BentoPDF"
rootCheck

WSU_BENTOPDF_DIR="/var/www/bentopdf"

fxTitle "📂 Switching to ${WSU_BENTOPDF_DIR}..."
cd "$WSU_BENTOPDF_DIR" || fxCatastrophicError "Error switching to ${WSU_BENTOPDF_DIR}!"
if [[ "$(pwd -P)" != "$WSU_BENTOPDF_DIR" ]]; then
  fxCatastrophicError "ERROR: current directory is '$(pwd -P)', expected '$WSU_BENTOPDF_DIR'"
fi

pwd


fxTitle "👮🏻 Resetting permissions..."
chown webstackup:www-data $WSU_BENTOPDF_DIR -R
chmod ugo= $WSU_BENTOPDF_DIR -R
chmod u=rwx,go=rX $WSU_BENTOPDF_DIR -R


fxTitle "🏗️ Building..."
sudo -u webstackup -H npm install
sudo -u webstackup -H SIMPLE_MODE=true npm run build


fxTitle "🚀 Running..."
cd $WSU_BENTOPDF_DIR/dist || fxCatastrophicError "Error switching to dist!"
sudo -u www-data -H python3 -m http.server 3000 --bind 0.0.0.0


fxEndFooter
