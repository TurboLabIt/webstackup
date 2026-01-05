#!/usr/bin/env bash
### AUTOMATIC SFTP-ONLY (NO-SSH LOGIN) USER  GENERATOR BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/account/generate-sftp-only-user.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/generate-sftp-only-user.sh | sudo WSU_SFTP_ONLY_USERNAME=my-user bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "👤 SFTP-only user generator"
rootCheck


if [ ! -z "${1}" ]; then
  WSU_SFTP_ONLY_USERNAME=${1}
fi

if [ -z "${WSU_SFTP_ONLY_USERNAME}" ]; then
  fxCatastrophicError "You must provide the new username as argument or WSU_SFTP_ONLY_USERNAME"
fi


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}setup-if-stale.sh" ]; then
  "${WSU_DIR}setup-if-stale.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "👨‍👩‍👧‍👧 Generating the sftp-only group..."
if ! getent group "sftp-only" &>/dev/null; then
  groupadd --system sftp-only
else
  fxInfo "sftp-only group already exists, skipping 🦘"  
fi





fxEndFooter
