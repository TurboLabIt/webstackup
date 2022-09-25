#!/usr/bin/env bash

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🐫 my-app-template"
rootCheck

WSU_MAP_DEPLOY_TO_PATH=$1
WSU_MAP_DOMAIN=$2
WSU_MAP_NAME=$3


fxTitle "📂 Deploy-to path"
while [ -z "$WSU_MAP_DEPLOY_TO_PATH" ] || [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ]
do
  WSU_MAP_CURR_DIR=$(pwd)
  echo "🤖 Provide the path to your project root (e.g.: /var/www/my-app)"
  read -p "Hit Enter for ${WSU_MAP_CURR_DIR}: " WSU_MAP_DEPLOY_TO_PATH  < /dev/tty
  if [ -z "$WSU_MAP_DEPLOY_TO_PATH" ]; then
    WSU_MAP_DEPLOY_TO_PATH=$WSU_MAP_CURR_DIR
  fi
  
  if [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ]; then
    fxCatastrophicError "Directory ##${WSU_MAP_DEPLOY_TO_PATH}## doesn't exist!" "proceed"
    WSU_MAP_DEPLOY_TO_PATH=
    echo ""
  fi
done

WSU_MAP_DEPLOY_TO_PATH=${WSU_MAP_DEPLOY_TO_PATH%*/}/
fxOK "OK, $WSU_MAP_DEPLOY_TO_PATH"

WSU_MAP_MY_APP=$(basename ${WSU_MAP_DEPLOY_TO_PATH%*/})
fxOK "OK, $WSU_MAP_MY_APP"


fxTitle "🌎 Real app domain to replace the placeholder my-app.com"
while [ -z "$WSU_MAP_DOMAIN" ]
do
  read -p "🤖 Provide the domain of your app (e.g.: www.turbolab.it or turbolab.it): " WSU_MAP_DOMAIN  < /dev/tty
done

WSU_MAP_DOMAIN=${WSU_MAP_DOMAIN%*/}
fxOK "OK, $WSU_MAP_DOMAIN"


fxTitle "📛 Real app name to replace my-app"
while [ -z "$WSU_MAP_NAME" ]
do
  read -p "🤖 Provide the name of your app (e.g.: TurboLab.it): " WSU_MAP_NAME  < /dev/tty
done

fxOK "OK, $WSU_MAP_NAME"


function wsuMapReplace()
{
  find /tmp/my-app-template \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s|${1}|${2}|g"
}


fxTitle "⏬ Downloading my-app-template..."
WSU_MAP_ORIGIN=/usr/local/turbolab.it/webstackup/my-app-template/
if [ -d "${WSU_MAP_ORIGIN}" ]; then

  mkdir /tmp/my-app-template
  cp -r ${WSU_MAP_ORIGIN}. /tmp/my-app-template/
  
  ## log directory
  mkdir -p /tmp/my-app-template/var/log
  
  rm -f /tmp/my-app-template/setup*.sh
  
  wsuMapReplace "/var/www/my-app" "${WSU_MAP_DEPLOY_TO_PATH%*/}"
  wsuMapReplace "my-app.com" "${WSU_MAP_DOMAIN}"
  wsuMapReplace "my-app" "${WSU_MAP_MY_APP}"
  wsuMapReplace "My App Name" "${WSU_MAP_NAME}"
  
  ## oops..
  wsuMapReplace "webstackup/blob/master/${WSU_MAP_MY_APP}" "webstackup/blob/master/my-app"
  
  curl -Lo "/tmp/my-app-template/.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore?$(date +%s)
  
  chown webstackup:www-data /tmp/my-app-template -R
  chmod u=rwx,go=rX /tmp/my-app-template -R
  chmod u=rwx,go=rx /tmp/my-app-template/scripts/*.sh -R
  chmod u=rwx,go=rwX /tmp/my-app-template/var -R
  
  cp -a /tmp/my-app-template/. "${WSU_MAP_DEPLOY_TO_PATH}"
  rm -rf /tmp/my-app-template/
else
  fxCatastrophicError "Sorry, this is not implemented yet!"
fi

fxEndFooter
