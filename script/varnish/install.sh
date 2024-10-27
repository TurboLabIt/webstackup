#!/usr/bin/env bash
### AUTOMATIC VARNISH INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/varnish/install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/varnish/install.sh | sudo bash
#
# Based on: https://turbolab.it/4221 | https://www.varnish-software.com/developers/tutorials/installing-varnish-ubuntu/

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 VARNISH installer"
rootCheck

fxTitle "Removing any old previous instance..."
apt purge --auto-remove varnish* -y
rm -rf /etc/varnish

## installing/updating WSU
#WSU_DIR=/usr/local/turbolab.it/webstackup/
#if [ ! -f "${WSU_DIR}setup.sh" ]; then
  #curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) | sudo bash
#fi

#source "${WSU_DIR}script/base.sh"

fxTitle "Installing prerequisites..."
apt update -qq
apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y

fxTitle "Installing additional utilities..."
apt install software-properties-common openssl zip unzip nano -y

fxTitle "Import the official varnish signing key..."
curl -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/varnish-archive-keyring.gpg >/dev/null


fxTitle "Creating the apt source file..."
. /etc/os-release
echo "deb [signed-by=/usr/share/keyrings/varnish-archive-keyring.gpg] \
https://packagecloud.io/varnishcache/varnish60lts/$ID/ $VERSION_CODENAME main" | sudo tee /etc/apt/sources.list.d/varnish.list

fxTitle "Set up repository pinning to prefer our packages over distribution-provided ones..."
echo -e "Package: varnish varnish-*\nPin: release o=packagecloud.io/varnishcache/*\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99varnish
exit

fxTitle "apt install varnish..."
apt update -qq
apt install varnish -y


fxTitle "Final varnish restart..."
varnish -t
service varnish restart

fxEndFooter
