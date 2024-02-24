## Run phpunit tests of your bundle by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/blob/master/script/php/test-runner-bundle.sh
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/test-runner-bundle.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/test-runner-bundle.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

echo ""
SCRIPT_NAME=test-runner-bundle

## https://github.com/TurboLabIt/bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧪 Test Runner"
