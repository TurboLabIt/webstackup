#!/usr/bin/env bash
### EMAIL TOOLS GUI by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/email/zzmail.sh
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
TITLE="Email server management GUI"
fxHeader "$TITLE"
rootCheck


if [ -z "$(command -v dialog)" ]; then
  apt install dialog -y -qq
fi


HEIGHT=25
WIDTH=75
CHOICE_HEIGHT=30
BACKTITLE="WEBSTACK.UP - TurboLab.it"
MENU="Choose one task:"

OPTIONS=(
  1 "📤  Send a test email"
  2 "📫  New mailbox"
  3 "🕵️‍  Read a mailbox"
  4 "📜  Show mail.log")

CHOICE=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --menu "$MENU" \
        $HEIGHT $WIDTH $CHOICE_HEIGHT \
        "${OPTIONS[@]}" \
        2>&1 >/dev/tty)

clear


case $CHOICE in
  1) bash /usr/local/turbolab.it/webstackup/script/mail/send-test-email.sh;;
  2) bash /usr/local/turbolab.it/webstackup/script/dovecot/new-mailbox.sh;;
  3) bash /usr/local/turbolab.it/webstackup/script/dovecot/read-mailbox.sh;;
  4) tail -f /var/log/mail.log /var/log/dovecot.log;;
esac
