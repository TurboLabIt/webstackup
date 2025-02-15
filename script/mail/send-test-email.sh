#!/usr/bin/env bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📧 Send test email"
rootCheck

fxTitle "Checking the mail command..."
if [ -z $(command -v mail) ]; then

  fxWarning "Mail is not installed. Installing it now..."
  apt install mailutils -y
fi


fxTitle "Checking mailname from /etc/mailname..."
if [ -f "/etc/mailname" ]; then

  WSU_MAILNAME=$(cat /etc/mailname)
  WSU_MAILNAME="${WSU_MAILNAME//[[:space:]]/}"
  fxOK "Your mailname is ##${WSU_MAILNAME}##"
  WSU_TEST_EMAIL_DEFAULT_FROM=test@${WSU_MAILNAME}
  WSU_TEST_EMAIL_DEFAULT_TO=info@${WSU_MAILNAME}
  
else

  fxWarning "Mailname doesn't exist. User discretion is advised"
  WSU_TEST_EMAIL_DEFAULT_FROM=test@example.com
  WSU_TEST_EMAIL_DEFAULT_TO=info@example.com

fi


fxTitle "Sender address (From:)"
if [ ! -z "${1}" ]; then

  fxInfo "Sender address (From:) set from command line"
  WSU_TEST_EMAIL_FROM=${1}
fi

while [ -z "$WSU_TEST_EMAIL_FROM" ]; do
  
  echo "🤖 Provide the sender email address (From:) or hit Enter for ##${WSU_TEST_EMAIL_DEFAULT_FROM}##"
  read -p ">> " WSU_TEST_EMAIL_FROM  < /dev/tty
  if [ -z "$WSU_TEST_EMAIL_FROM" ]; then
    WSU_TEST_EMAIL_FROM=$WSU_TEST_EMAIL_DEFAULT_FROM
  fi

done

WSU_TEST_EMAIL_FROM="${WSU_EMAIL_ADDRESS_TO_READ//[[:space:]]/}"
fxOK "Got it! ##$WSU_TEST_EMAIL_FROM##"


fxTitle "Recipient address (To:)"
if [ ! -z "${2}" ]; then

  fxInfo "Recipient address (To:) set from command line"
  WSU_TEST_EMAIL_TO=${2}
fi

while [ -z "$WSU_TEST_EMAIL_TO" ]; do
  
  echo "🤖 Provide the recipient email address (To:) or hit Enter for ##${WSU_TEST_EMAIL_DEFAULT_TO}##"
  read -p ">> " WSU_TEST_EMAIL_TO  < /dev/tty
  if [ -z "$WSU_TEST_EMAIL_TO" ]; then
    WSU_TEST_EMAIL_TO=$WSU_TEST_EMAIL_DEFAULT_TO
  fi

done

WSU_TEST_EMAIL_TO="${WSU_TEST_EMAIL_TO//[[:space:]]/}"
fxOK "Got it! ##$WSU_TEST_EMAIL_TO##"


fxTitle "Fast/slow mode"
if [ "${3}" == "fast" ]; then

  fxInfo "Fast mode set from the command line"
  WSU_TEST_EMAIL_MODE=fast

elif [ "${3}" == "slow" ]; then

  fxInfo "Slow mode set from the command line"
  WSU_TEST_EMAIL_MODE=slow
fi

while [ -z "$WSU_TEST_EMAIL_MODE" ]; do
  
  echo "🤖 Wipe the log and restart the email services? Hit Enter for 'yes'"
  read -p ">> " -n 1 -r  < /dev/tty
  if [[ ! "$REPLY" =~ ^[Nn0]$ ]]; then
    WSU_TEST_EMAIL_MODE=slow
  else
    WSU_TEST_EMAIL_MODE=yes
  fi

done

if [ "$WSU_TEST_EMAIL_MODE" == slow ]; then

  fxTitle "Wiping the mail.log..."
  if [ -f /var/log/mail.log ]; then
    echo "" > /var/log/mail.log
  else
    fxInfo "Log file not found. Skipping 🦘"
  fi

  fxTitle "Wiping dovecot.log..."
  if [ -f /var/log/dovecot.log ]; then
    echo "" > /var/log/dovecot.log
  else
    fxInfo "Log file not found. Skipping 🦘"
  fi

  fxTitle "Restarting Postfix..."
  if systemctl is-active --quiet postfix.service; then
    sudo systemctl restart postfix
    sudo systemctl status postfix --no-pager
  else
    fxInfo "Postfix not found. Skipping 🦘"
  fi

  fxTitle "Restarting OpenDKIM..."
  if systemctl is-active --quiet opendkim.service; then
    sudo systemctl restart opendkim
    sudo systemctl status opendkim --no-pager
  else
    fxWarning "OpenDKIM not found. Skipping 🦘"
  fi

  fxTitle "Restarting Dovecot..."
  if systemctl is-active --quiet dovecot.service; then
    sudo systemctl restart dovecot
    sudo systemctl status dovecot --no-pager
  else
    fxWarning "Dovecot not found. Skipping 🦘"
  fi
  
fi


fxTitle "Sending the actual email (finally!)..."
## https://serverfault.com/q/1152427/188704
## https://www.telemessage.com/developer/faq/how-do-i-encode-non-ascii-characters-in-an-email-subject-line/
EMAIL_SUBJECT=$(echo "🧪 Test email sent from $(hostname) 🧪" | base64)
echo "Hi! This is a test sent from $(hostname) on $(date) (server-time)" | \
  mail -s "=?utf-8?B?${EMAIL_SUBJECT}?=" -a \
  FROM:"${WSU_TEST_EMAIL_FROM}" "${WSU_TEST_EMAIL_TO}"

sleep 5

fxTitle "📜 Mail log"
if [ -f /var/log/mail.log ]; then
  tail -n 100 /var/log/mail.log | grep --color=always -i ${WSU_TEST_EMAIL_TO} -B10 -A10
else
  fxInfo "mail.log not found. Skipping 🦘"
fi

if [ -f /var/log/dovecot.log ]; then
  tail -n 100 /var/log/dovecot.log | grep --color=always -i ${WSU_TEST_EMAIL_TO} -B10 -A10
else
  fxInfo "dovecot.log not found. Skipping 🦘"
fi


fxEndFooter
