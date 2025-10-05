#!/usr/bin/env bash
### CONFIGURE EXTERNAL RELAY FOR LOCAL POSTFIX BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mail/postfix-external-relay.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mail/postfix-external-relay.sh | sudo bash
#

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📮 Activate external relay"
rootCheck
fxWarning "Work in progress! Prepare to copy-paste from https://github.com/TurboLabIt/webstackup/blob/master/config/postfix/external-relay-template.md"
fxAskConfirmation


fxTitle "Installing prerequisites..."
if [ -z $(command -v nano) ]; then apt update && apt install nano -y; fi


fxTitle "Opening files sequence..."
nano /etc/postfix/main.cf
nano /etc/postfix/sasl_passwd && postmap /etc/postfix/sasl_passwd
chown root:root /etc/postfix/sasl_passw* && chmod u=rw,go= /etc/postfix/sasl_passw*
service postfix restart && service postfix status --no-pager


if [ -f "${WEBSTACKUP_SCRIPT_DIR}mail/send-test-email.sh" ]; then

  bash ${WEBSTACKUP_SCRIPT_DIR}mail/send-test-email.sh

else

  fxTitle "Sending test email..."
  fxWarning "Relay configured, but unable to test it (webstackup is missing)"
  fxEndFooter

fi
