#!/usr/bin/env bash
### EMAIL TOOLS GUI by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/email/zzmail.sh

TITLE="Email server management GUI"
OPTIONS=(
  1 "📤  Send a test email"
  2 "📫  New mailbox"
  3 "🕵️‍  Read a mailbox (Dovecot)"
  4 "📜  Show email logs"
  5 "🔏  Activate Let's Encrypt certificate"
  6 "📧  DKIM a domain"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1) bash ${WEBSTACKUP_SCRIPT_DIR}mail/send-test-email.sh;;
  2) bash ${WEBSTACKUP_SCRIPT_DIR}dovecot/new-mailbox.sh;;
  3) bash ${WEBSTACKUP_SCRIPT_DIR}dovecot/read-mailbox.sh;;
  4) fxTitle "📜 Mail log" && tail -f /var/log/mail.log /var/log/dovecot.log;;
  5) bash ${WEBSTACKUP_SCRIPT_DIR}dovecot/replace-certificate.sh;;
  6) bash ${WEBSTACKUP_SCRIPT_DIR}mail/dkim.sh;;
esac
