#!/usr/bin/env bash
### LET'S ENCRYPT INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/https/letsencrypt-install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/letsencrypt-install.sh | sudo bash
#
# Based on: https://certbot.eff.org/instructions | https://turbolab.it/886 | https://turbolab.it/4301

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Let's Encrypt installer"
rootCheck


fxTitle "Repos update..."
fxAptUpdate


fxContainerDetection
IS_CONTAINER="$?"


if [ "${IS_CONTAINER}" != "1" ]; then

  fxTitle "Installing prerequisites..."
  apt install snapd -y
fi


fxTitle "Removing any old previous instance..."
rm -rf /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt /usr/local/bin/acme-dns-client
apt purge --auto-remove certbot* -y
snap remove --purge certbot
rm -rf /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt /usr/local/bin/acme-dns-client


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}setup-if-stale.sh" ]; then
  "${WSU_DIR}setup-if-stale.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "Installing certbot..."
if [ "${IS_CONTAINER}" == "1" ]; then

  fxInfo "Container detected: using apt (fallback)"
  apt install certbot -y

else

  fxInfo "No container detected: using snap (recommended)"
  snap install --classic certbot
  fxLinkBin /snap/bin/certbot
fi


fxTitle "Deploying post-renewal hook...."
mkdir -p /etc/letsencrypt/renewal-hooks/deploy/
fxLink ${WEBSTACKUP_SCRIPT_DIR}https/certificate-renewal-action.sh /etc/letsencrypt/renewal-hooks/deploy/webstackup-certificate-renewal-action.sh


fxTitle "Linking the zzfirewall hooks..."
## zzfirewall setup.sh links them only if certbot is already installed, and the rm -rf above
## wipes them: linking them here too lets the two be installed in either order
ZZFIREWALL_HOOKS_DIR=/usr/local/turbolab.it/zzfirewall/hooks/
if [ -d "${ZZFIREWALL_HOOKS_DIR}" ]; then

  mkdir -p /etc/letsencrypt/renewal-hooks/pre/ /etc/letsencrypt/renewal-hooks/post/
  fxLink ${ZZFIREWALL_HOOKS_DIR}lets-encrypt-web-01-pre.sh /etc/letsencrypt/renewal-hooks/pre/zzfirewall-web-open.sh
  fxLink ${ZZFIREWALL_HOOKS_DIR}lets-encrypt-web-90-post.sh /etc/letsencrypt/renewal-hooks/post/zzfirewall-web-close.sh

else

  fxInfo "##${ZZFIREWALL_HOOKS_DIR}## not found, skipping 🦘"
fi


fxTitle "Removing the cron file (unused with systemd)..."
rm -f /etc/cron.d/certbot

fxTitle "Checking the systemd renewal timer..."
systemctl list-timers --all | grep certbot


## https://github.com/acme-dns/acme-dns-client/releases/latest
URL="https://github.com/acme-dns/acme-dns-client/releases/download/v0.3/acme-dns-client_0.3_linux_$(fxGetCpuArch).tar.gz"
fxInfo "Downloading ${URL} ..."
curl -Lo /tmp/acme-dns-client.tar.gz "${URL}"

fxTitle "Installing acme-dns-client...."
tar -zxf /tmp/acme-dns-client.tar.gz -C /usr/local/bin/ acme-dns-client
rm -f /tmp/acme-dns-client.tar.gz
chown root:root /usr/local/bin/acme-dns-client
chmod u=rwx,go=rx /usr/local/bin/acme-dns-client


fxTitle "To request a certificate"
fxMessage "Run: webstackup -> 🔏 Let's Encrypt"


fxEndFooter
