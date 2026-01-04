#!/usr/bin/env bash
### USE LET'S ENCRYPT CERTIFICATE WITH DOVECOT BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/dovecot/replace-certificate.sh

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🔏 Use Let's Encrypt certificate with Dovecot"
rootCheck


DOVECOT_CERT_KEY=/etc/dovecot/private/dovecot.key
DOVECOT_CERT_CRT=/etc/dovecot/private/dovecot.pem

fxTitle "Current certificate..."
ls -l /etc/dovecot/private/


fxMailNameWarning


if [ -z "${WSU_MAILNAME}" ]; then
  fxCatastrophicError "Cannot proceed without a mailname"
fi


fxTitle "Checking certificate..."
CERT_KEY=/etc/letsencrypt/live/${WSU_MAILNAME}/privkey.pem
CERT_CRT=/etc/letsencrypt/live/${WSU_MAILNAME}/fullchain.pem

if [ ! -f "$CERT_KEY" ]; then
  fxCatastrophicError "Certificate private key not found in ##${CERT_KEY}##"
fi

if [ ! -f "$CERT_CRT" ]; then
  fxCatastrophicError "Certificate file not found in ##${CERT_CRT}##"
fi

fxOK "YES! Certificate file found in ##${CERT_CRT}##! 🚀"


fxTitle "Replacing the cert..."
fxLink "$CERT_KEY" "$DOVECOT_CERT_KEY"
echo ""
fxLink "$CERT_CRT" "$DOVECOT_CERT_CRT"


fxTitle "Current certificate..."
ls -l /etc/dovecot/private/


fxEndFooter
