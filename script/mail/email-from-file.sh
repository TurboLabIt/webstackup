#!/usr/bin/env bash

# EMAIL_FROM_NAME="TurboLab.it"
# EMAIL_FROM_ADDRESS="no-reply@turbolab.it"
# EMAIL_SUBJECT="🥳 The new site is ready!"
# HTML_FILE_PATH="${PROJECT_DIR}email/new-site-ready.html"
# RECIPIENTS_LIST="${PROJECT_DIR}var/recipients.txt"


## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📧 Send email to file recipients"

fxMailNameWarning


fxTitle "Checking parameters..."
if [ -z "$EMAIL_FROM_NAME" ]; then
  fxCatastrophicError "EMAIL_FROM_NAME is empty or not provided."
fi

if [ -z "$EMAIL_FROM_ADDRESS" ]; then
  fxCatastrophicError "EMAIL_FROM_ADDRESS is empty or not provided."
fi

if [ -z "$EMAIL_SUBJECT" ]; then
  fxCatastrophicError "EMAIL_SUBJECT is empty or not provided."
fi

if [ -z "$HTML_FILE_PATH" ]; then
  fxCatastrophicError "HTML_FILE_PATH is empty or not provided."
fi

if [ -z "$RECIPIENTS_LIST" ]; then
  fxCatastrophicError "RECIPIENTS_LIST is empty or not provided."
fi


if [ ! -f "$HTML_FILE_PATH" ]; then
  fxCatastrophicError "HTML file ##$HTML_FILE_PATH## not found."
fi

if [ ! -f "$RECIPIENTS_LIST" ]; then
  fxCatastrophicError "Recipient list file ##$RECIPIENTS_LIST## not found."
fi


fxTitle "Checking the mail command..."
if [ -z $(command -v mail) ]; then

  fxWarning "Mail is not installed. Installing it now..."
  sudo apt update -qq && sudo apt install mailutils -y
fi


while IFS= read -r LINE
do

  RECIPIENT_ADDRESS=$(fxTrim $LINE)
  FIRSTCHAR="${RECIPIENT_ADDRESS:0:1}"
  if [ "$FIRSTCHAR" != "#" ] && [ "$FIRSTCHAR" != "" ]; then

    echo "✉️ $RECIPIENT_ADDRESS"
    mail -s "=?utf-8?B?${EMAIL_SUBJECT}?=" \
         -a "From: $EMAIL_FROM_NAME <$EMAIL_FROM_ADDRESS>" \
         -a "Content-Type: text/html" \
         "$RECIPIENT_ADDRESS" < "$HTML_FILE_PATH"

    sleep 1
  fi

done < "$RECIPIENTS_LIST"


fxEndFooter
