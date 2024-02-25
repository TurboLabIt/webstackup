## https://github.com/TurboLabIt/bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "${SCRIPT_TITLE}"


if [ -f /usr/local/turbolab.it/webstackup/script/base.sh ]; then

  source /usr/local/turbolab.it/webstackup/script/base.sh
  
else

  ## Absolute path to this script, e.g. /home/user/bin/foo.sh
  SCRIPT_FULLPATH=$(readlink -f "$0")
  
  ## Absolute path this script is in, thus /home/user/bin
  SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/
  
  ##
  INITIAL_DIR=$(pwd)
  PROJECT_DIR=$(readlink -m "${SCRIPT_DIR}..")/
fi


cd "$PROJECT_DIR"


fxTitle "Requirements check..."
function checkReqCommand()
{
  if [ -z $(command -v $1) ]; then
  
    echo "🛑 $1 is missing!"
    REQ_CHECK_FAILURE=1
    
  else

    echo "✅ $1 is installed"
  fi
}

checkReqCommand php
checkReqCommand composer
checkReqCommand symfony

if [ -s "${PROJECT_DIR}.php-version" ]; then

  echo "✅ .php-version exists. PHP version set to ##$(cat .php-version)##"

else

  echo "🛑 ##${PROJECT_DIR}.php-version## is missing or empty! It must contain the PHP version to use. This will build it for you:"
  fxMessage "echo '8.3' > .php-version"
  touch .php-version
  REQ_CHECK_FAILURE=1
fi

