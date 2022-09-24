#!/usr/bin/env bash

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "my-app-template"
rootCheck

WSU_MAP_DEPLOY_TO_PATH=$1

fxTitle "📂 Deploy-to path"
while [ -z "$WSU_MAP_DEPLOY_TO_PATH" ] || [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ]
do
  WSU_MAP_CURR_DIR=$(pwd)
  echo "🤖 Provide the path to your project root (e.g.: /var/www/my-app)"
  read -p "Hit enter for ${WSU_MAP_CURR_DIR}: " WSU_MAP_DEPLOY_TO_PATH  < /dev/tty
  if [ -z "$WSU_MAP_DEPLOY_TO_PATH" ]; then
    WSU_MAP_DEPLOY_TO_PATH=$WSU_MAP_CURR_DIR
  fi
  
  if [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ];
    fxCatastrophicError "Directory ##${$WSU_MAP_DEPLOY_TO_PATH}## doesn't exist!" "proceed"
  fi  
done

fxOK "OK, $WSU_MAP_DEPLOY_TO_PATH"


fxTitle "⏬ Downloading my-app-template..."
WSU_MAP_ORIGIN=/usr/local/turbolab.it/webstackup/my-app-template
if [ -d "${WSU_MAP_ORIGIN}" ]; then
  echo cp -r "${WSU_MAP_ORIGIN}"/* 
else
  fxCatastrophicError "Sorry, this is not implemented yet!"
fi


fxTitle "⏬ Downloading some other external stuff..."
curl -Lo "${WSU_MAP_DEPLOY_TO_PATH}.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore?$(date +%s)
curl -Lo "${WSU_MAP_DEPLOY_TO_PATH}backup/.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore_contents?$(date +%s)


fxEndFooter
