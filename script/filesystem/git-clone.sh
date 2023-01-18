#!/usr/bin/env bash
### GUIDED PROJECT CLONING BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/filesystem/git-clone.sh
#

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🐑 Git clone wizard"
rootCheck

fxTitle "🌎 Enter the repository URL"
fxInfo "For example: git@github.com:TurboLabIt/html-pages.git or git@bitbucket.org:turbolabit/html-pages.git"
while [ -z "$WSU_MAP_REPO_URL" ]; do

  echo "🤖 Provide the URL of the repository"
  read -p ">> " WSU_MAP_REPO_URL  < /dev/tty

done

fxOK "OK, cloning from on ##$WSU_MAP_REPO_URL##"







while [ -z "$NEWSITE_REPO_URL" ]
do
  read -p "🤖 Provide the URL to clone (e.g.: git@github.com:TurboLabIt/webstackup.git): " NEWSITE_REPO_URL  < /dev/tty
  
  sudo -u webstackup -H git ls-remote ${NEWSITE_REPO_URL} -q
  if [ $? != 0 ]; then
  
    echo ""
	NEWSITE_REPO_URL=
	
  fi
  
done

printMessage "ℹ $NEWSITE_REPO_URL"




fxEndFooter
