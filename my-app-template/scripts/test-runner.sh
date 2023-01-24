#!/usr/bin/env bash
## Run the project tests and check the result
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/test-runner.sh

source $(dirname $(readlink -f $0))/script_begin.sh
# if you're testing a package, use this instead:
#source "/usr/local/turbolab.it/webstackup/script/base.sh"
#APP_NAME=MyPackageName
#EXPECTED_USER=$(logname)

fxHeader "🧪 ${APP_NAME} Test Runner"

# ... pre-test stuff ...

# https://github.com/TurboLabIt/webstackup/tree/master/script/php/test-runner-package.sh
source "/usr/local/turbolab.it/webstackup/script/php/test-runner-package.sh"

fxTitle "🧹 Cleaning up..."
#rm -rf /tmp/any-temp-dir

source $(dirname $(readlink -f $0))/script_end.sh
# if you're testing a package, just use this instead:
#fxEndFooter
