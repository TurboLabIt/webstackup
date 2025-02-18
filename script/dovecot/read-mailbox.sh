#!/usr/bin/env bash
### AUTOMATIC DOVECOT MAILBOX READER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/dovecot/read-mailbox.sh

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🕵 DOVECOT email reader"
rootCheck

fxMailNameWarning


fxTitle "Mailbox address"
if [ ! -z "${1}" ]; then

  fxInfo "Email address set from command line"
  WSU_EMAIL_ADDRESS_TO_READ=${1}
fi

while [ -z "$WSU_EMAIL_ADDRESS_TO_READ" ]; do
  
  echo "🤖 Provide the email address to check or hit Enter for ##${WSU_MAIL_DEFAULT_ADDRESS}##"
  read -p ">> " WSU_EMAIL_ADDRESS_TO_READ  < /dev/tty
  if [ -z "$WSU_EMAIL_ADDRESS_TO_READ" ]; then
    WSU_EMAIL_ADDRESS_TO_READ=$WSU_MAIL_DEFAULT_ADDRESS
  fi

done

WSU_EMAIL_ADDRESS_TO_READ="${WSU_EMAIL_ADDRESS_TO_READ//[[:space:]]/}"
fxOK "Got it! ##$WSU_EMAIL_ADDRESS_TO_READ##"


fxTitle "📫 Inbox of $WSU_EMAIL_ADDRESS_TO_READ"
sudo doveadm fetch -u $WSU_EMAIL_ADDRESS_TO_READ 'hdr.from hdr.subject hdr.date' mailbox INBOX | perl -MEncode -ne 'binmode STDOUT, ":utf8"; print decode("MIME-Header", $_)' | awk '
/hdr.from:/ {from = substr($0, index($0, ":") + 2)}
/hdr.subject:/ {subject = substr($0, index($0, ":") + 2)}
/hdr.date:/ {date = substr($0, index($0, ":") + 6); print "📅 " date " 🧔 From: " from " 📰 Subj: " subject}' | sed 's/^ *//'

fxEndFooter
