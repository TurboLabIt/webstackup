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

fxTitle "👤 Group and user check"
if ! getent group "www-data" &>/dev/null; then
  fxWarning "www-data group NOT found!"
  USER_FAILURE=1
fi

if ! id "webstackup" &>/dev/null; then
  fxWarning "webstackup user NOT found!"
  fxMessage "To create it now:"
  fxMessage "sudo useradd -G www-data webstackup --shell=/bin/false --create-home"
  USER_FAILURE=1
fi

if [ ! -z "${USER_FAILURE}" ]; then
 fxCatastrophicError "webstackup:www-data failure"
fi

fxOK "webstackup:www-data OK"


fxTitle "📛 Enter the name of the project"
fxInfo "For example: \"TurboLab.it\" or \"My Amazing Shop\" - YES, you can use spaces here!"
while [ -z "$WSU_MAP_NAME" ]
do
  echo "🤖 Provide the name of of the project"
  read -p ">> " WSU_MAP_NAME  < /dev/tty
done

fxOK "OK, working on ##$WSU_MAP_NAME##"


## auto-generating a candidate APP_NAME
WSU_MAP_APP_NAME_DEFAULT=$(echo "$WSU_MAP_NAME" | tr '[:upper:]' '[:lower:]')
WSU_MAP_APP_NAME_DEFAULT=${WSU_MAP_APP_NAME_DEFAULT// /-}


fxTitle "🌎 Enter the domain"
fxInfo "For example: \"turbolab.it\" or \"www.turbolab.it\" or \"my-shop.com\""
fxWarning "Please use the PRODUCTION domain"
WSU_MAP_DOMAIN_DEFAULT=${WSU_MAP_APP_NAME_DEFAULT}.com
while [ -z "$WSU_MAP_DOMAIN" ]
do
  echo "🤖 Provide the domain or hit Enter for ##${WSU_MAP_DOMAIN_DEFAULT}##"
  read -p ">> " WSU_MAP_DOMAIN  < /dev/tty
  if [ -z "$WSU_MAP_DOMAIN" ]; then
    WSU_MAP_DOMAIN=$WSU_MAP_DOMAIN_DEFAULT
  fi
done

fxOK "Acknowledged, domain is ##$WSU_MAP_DOMAIN##"


fxTitle "🖥️ Choose the APP_NAME"
fxInfo "For example: \"turboLab_it\" or \"my-amazing-shop\""
fxWarning "Lowercase letters [a-z] and numbers [0-9] only!"
while [ -z "$WSU_MAP_APP_NAME" ]
do
  echo "🤖 Provide the APP_NAME or hit Enter for ##${WSU_MAP_APP_NAME_DEFAULT}##"
  read -p ">> " WSU_MAP_APP_NAME  < /dev/tty
  if [ -z "$WSU_MAP_APP_NAME" ]; then
    WSU_MAP_APP_NAME=$WSU_MAP_APP_NAME_DEFAULT
  fi
done

WSU_MAP_APP_NAME=$(echo "$WSU_MAP_APP_NAME" | tr '[:upper:]' '[:lower:]')
WSU_MAP_APP_NAME=${WSU_MAP_APP_NAME// /-}

fxOK "Got it, APP_NAME is ##$WSU_MAP_APP_NAME##"


fxTitle "📂 Choose the root path"
WSU_MAP_DEPLOY_TO_PATH_DEFAULT=/var/www/${WSU_MAP_APP_NAME}
fxWarning "You should really accept the default 😉"
while [ -z "$WSU_MAP_DEPLOY_TO_PATH" ] || [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ]
do
  echo "🤖 Provide the path (use TAB!) or hit Enter for ##${WSU_MAP_DEPLOY_TO_PATH_DEFAULT}##"
  read -ep ">> " WSU_MAP_DEPLOY_TO_PATH  < /dev/tty
  if [ -z "$WSU_MAP_DEPLOY_TO_PATH" ]; then
    WSU_MAP_DEPLOY_TO_PATH=$WSU_MAP_DEPLOY_TO_PATH_DEFAULT
  fi
  
  if [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ] && [ -d "$(dirname "$WSU_MAP_DEPLOY_TO_PATH")" ]; then
    mkdir -p "$WSU_MAP_DEPLOY_TO_PATH"
  fi
  
  if [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ]; then
    fxWarning "Directory ##${WSU_MAP_DEPLOY_TO_PATH}## doesn't exist!" "proceed"
    WSU_MAP_DEPLOY_TO_PATH=
    echo ""
  fi
done

WSU_MAP_DEPLOY_TO_PATH=${WSU_MAP_DEPLOY_TO_PATH%*/}/
fxOK "Aye, aye! The app root path is ##$WSU_MAP_DEPLOY_TO_PATH##"


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
  wsuMapReplace "my-app" "${WSU_MAP_APP_NAME}"
  wsuMapReplace "My App Name" "${WSU_MAP_NAME}"
  
  ## oops..
  wsuMapReplace "webstackup/blob/master/${WSU_MAP_APP_NAME}" "webstackup/blob/master/my-app"
  
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
