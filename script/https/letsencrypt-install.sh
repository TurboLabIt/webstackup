#!/usr/bin/env bash
### LET'S ENCRYPT INSTALLER BY WEBSTACK.UP
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


fxTitle "Removing any old previous instance..."
apt purge --auto-remove certbot* -y
rm -rf /etc/letsencrypt /usr/local/acme-dns-client /usr/local/bin/acme-dns-client


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}setup-if-stale.sh" ]; then
  "${WSU_DIR}setup-if-stale.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "Installing prerequisites..."
apt update -qq
apt install snapd -y


fxTitle "Installing certbot..."
snap install --classic certbot
fxLinkBin /snap/bin/certbot


fxTitle "Deploying post-renewal hook...."
fxLink ${WEBSTACKUP_SCRIPT_DIR}https/certificate-renewal-action.sh /etc/letsencrypt/renewal-hooks/deploy/webstackup-certificate-renewal-action.sh


fxTitle "Installing acme-dns-client...."
mkdir /usr/local/acme-dns-client
curl -o /usr/local/acme-dns-client/acme-dns-client.tar.gz https://github.com/acme-dns/acme-dns-client/releases/download/v0.3/acme-dns-client_0.3_linux_$(fxGetCpuArch).tar.gz
tar -zxvf /usr/local/acme-dns-client/acme-dns-client.tar.gz -C /usr/local/acme-dns-client/
rm -f /usr/local/acme-dns-client/acme-dns-client.tar.gz
fxLinkBin /usr/local/acme-dns-client/acme-dns-client
fxOK "acme-dns-client $(acme-dns-client --version) ready!"


fxEndFooter
