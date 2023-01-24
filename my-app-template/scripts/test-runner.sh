#!/usr/bin/env bash
## Run phpunit tests of the project
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/test-runner.sh

source $(dirname $(readlink -f $0))/script_begin.sh
# if you're testing a package, just set this instead:
#APP_NAME=MyPackageName

# https://github.com/TurboLabIt/webstackup/tree/master/script/php/test-runner-package.sh
source "/usr/local/turbolab.it/webstackup/script/php/test-runner-package.sh"

fxTitle "🧹 Cleaning up..."
#rm -rf /tmp/any-temp-dir

fxEndFooter
