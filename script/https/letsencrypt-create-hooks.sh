#!/usr/bin/env bash
## Let's Encrypt post-renewal hook
# https://certbot.eff.org/docs/using.html?highlight=hook#renewing-certificates
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/letsencrypt-create-hooks.sh | sudo bash
#
SCRIPT_NAME=letsencrypt-create-hooks

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🪝 LET'S ENCRYPT CREATE HOOKS"
rootCheck


if [ ! -d "/etc/letsencrypt/" ]; then
  fxCatastrophicError "##/etc/letsencrypt/## not found! Reinstall certbot: https://github.com/TurboLabIt/webstackup/blob/master/script/https/letsencrypt-install.sh"
fi


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}setup-if-stale.sh" ]; then
  "${WSU_DIR}setup-if-stale.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "📁 Setting up the hooks folder...."
mkdir -p /etc/letsencrypt/renewal-hooks/deploy/
rm -f /etc/letsencrypt/renewal-hooks/deploy/*


fxTitle "🪝 Deploying the post-renewal hook...."
mkdir -p /etc/letsencrypt/renewal-hooks/deploy/
rm -f /etc/letsencrypt/renewal-hooks/deploy/*
fxLink ${WEBSTACKUP_SCRIPT_DIR}https/certificate-renewal-action.sh /etc/letsencrypt/renewal-hooks/deploy/webstackup-certificate-renewal-action.sh


fxTitle "✅ Script deployed"
ls -latrh /etc/letsencrypt/renewal-hooks/deploy


fxTitle "🔃 Force-renewing certificates to test the hook..."
sudo certbot renew --dry-run && sudo certbot renew --force-renewal


fxEndFooter
