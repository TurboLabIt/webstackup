#!/usr/bin/env bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📧 Send test email"

fxTitle "Checking mailname from /etc/mailname..."
if [ -f "/etc/mailname" ]; then
  fxOK "Your mailname is ##$(cat /etc/mailname)##"
else
  fxWarning "Mailname doesn't exist. User discretion is advised"
fi


function argumentError()
{
  fxCatastrophicError "Bad arguments! Usage: send-test-email from@example.com to@example.com [fast]"
}


fxTitle "Checking sender address..."
if [ ! -z "${1}" ]; then
  fxInfo "Sender address set from command line: 🏠 ##${1}##"
  EMAIL_FROM_ADDRESS=${1}
fi

if [ ! -z "${EMAIL_FROM_ADDRESS}" ] && [ -z "${1}" ]; then
  fxInfo "Sender address variable found: 🏠 ##${EMAIL_FROM_ADDRESS}##"
fi

if [ -z "${EMAIL_FROM_ADDRESS}" ]; then
  argumentError
fi


fxTitle "Checking recipient address..."
if [ ! -z "${2}" ]; then
  fxInfo "Recipient address set from command line: 📇 ##${2}##"
  EMAIL_TO_ADDRESS=${2}
fi

if [ ! -z "${EMAIL_TO_ADDRESS}" ] && [ -z "${2}" ]; then
  fxInfo "Recipient address variable found: 📇 ##${EMAIL_TO_ADDRESS}##"
fi

if [ -z "${EMAIL_TO_ADDRESS}" ]; then
  argumentError
fi


fxTitle "Wiping /var/log/email.log..."
if [ -f "/var/log/mail.log" ]; then
  fxInfo "Mail log file found"
else
  fxWarning "Mail log file not found"
fi

if [ "${3}" == "fast" ]; then
  fxInfo "🦘 Skipping due to fast mode from command line"
  EMAIL_SKIP_WIPE_LOG=1
fi

if [ "${EMAIL_SKIP_WIPE_LOG}" == "1" ] && [ "${3}" != "fast" ]; then
  fxInfo "🦘 Skipping due to variable set"
fi

if [ "${EMAIL_SKIP_WIPE_LOG}" != "1" ] && [ -f "/var/log/mail.log" ]; then
  echo "" | sudo tee /var/log/mail.log
  fxOK "Log wiped"
fi


fxTitle "Restarting email services..."
if [ "${3}" == "fast" ]; then
  fxInfo "🦘 Skipping due to fast mode from command line"
  EMAIL_SKIP_SERVICES_RESTART=1
fi

if [ "${EMAIL_SKIP_SERVICES_RESTART}" == "1" ] && [ -z "${3}" ]; then
  fxInfo "🦘 Skipping due to variable set"
fi

if [ "${EMAIL_SKIP_SERVICES_RESTART}" != "1" ]; then

  ## postfix
  if systemctl is-active --quiet postfix.service; then
    sudo systemctl restart postfix
    sudo systemctl status postfix --no-pager
  else
    fxWarning "Postfix not found"
  fi


  ## opendkim
  if systemctl is-active --quiet opendkim.service; then
    sudo systemctl status opendkim
    sudo systemctl status opendkim --no-pager
  else
    fxWarning "OpenDKIM not found"
  fi
fi


fxTitle "Sending the actual email (finally!)..."
EMAIL_SUBJECT=$(echo "🧪 Hi! This is a test email from $(hostname) 🧪" | base64)
echo "Test from $(hostname) sent $(date) (server-time)" | \
  mail -s "=?utf-8?B?${EMAIL_SUBJECT}?=" -a \
  FROM:"${EMAIL_FROM_ADDRESS}" "${EMAIL_TO_ADDRESS}"

sleep 5
cat /var/log/mail.log

fxEndFooter
