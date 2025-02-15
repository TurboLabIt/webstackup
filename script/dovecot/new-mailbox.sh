#!/usr/bin/env bash
### AUTOMATIC DOVECOT MAILBOX CREATOR BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/dovecot/new-mailbox.sh

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📫 DOVECOT mailbox creator"
rootCheck
DOVECOT_PASSWD=/etc/dovecot/passwd


fxTitle "📧 Mailbox address"
fxInfo "For example: \"info@turbolab.it\""
while [ -z "$WSU_NEW_EMAIL_ADDRESS" ]; do

  echo "🤖 Provide the new email address"
  read -p ">> " WSU_NEW_EMAIL_ADDRESS  < /dev/tty

done

WSU_NEW_EMAIL_ADDRESS="${WSU_NEW_EMAIL_ADDRESS//[[:space:]]/}"
fxOK "Got it! ##$WSU_NEW_EMAIL_ADDRESS##"


# Check if the mailbox address already exists
if [ -f "$DOVECOT_PASSWD" ] && grep -q "^${WSU_NEW_EMAIL_ADDRESS}:" "$DOVECOT_PASSWD"; then
  fxCatastrophicError "This mailbox already exists!"
fi


fxTitle "🔑 Password"

## generating a candidate password
if [ "$WSU_NEW_EMAIL_PASSWORD" = "auto" ]; then
  WSU_NEW_EMAIL_PASSWORD="$(fxPasswordGenerator)"
fi

while [ -z "$WSU_NEW_EMAIL_PASSWORD" ]; do

  echo "🤖 Provide the new mailbox password (leave blank for autogeneration)"
  read -p ">> " WSU_NEW_EMAIL_PASSWORD  < /dev/tty
  if [ -z "$WSU_NEW_EMAIL_PASSWORD" ]; then
    WSU_NEW_EMAIL_PASSWORD="$(fxPasswordGenerator)"
  fi

done

fxOK "OK, the new mailbox password is ##$WSU_NEW_EMAIL_PASSWORD##"


fxTitle "🧠 Building the new account config..."
WSU_NEW_EMAIL_PASSWORD_HASH=$(doveadm pw -s SHA512-CRYPT -p "${WSU_NEW_EMAIL_PASSWORD}")
WSU_NEW_EMAIL_ROW=${WSU_NEW_EMAIL_ADDRESS}:${WSU_NEW_EMAIL_PASSWORD_HASH}::::::userdb_quota_rule=*:storage=50G
fxInfo "${WSU_NEW_EMAIL_ROW}"


fxTitle "🔨 Adding the account..."
if [ -f "$DOVECOT_PASSWD" ] && [ "$(tail -c1 "$DOVECOT_PASSWD")" != "" ]; then
  echo >> "$DOVECOT_PASSWD"
fi

echo "$WSU_NEW_EMAIL_ROW" >> "$DOVECOT_PASSWD"
fxOK "OK"


fxEndFooter
