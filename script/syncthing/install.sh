#!/usr/bin/env bash
### AUTOMATIC SYNCTHING INSTALL BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/syncthing/install.sh | sudo bash
#
# Based on: https://apt.syncthing.net

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🔄 Syncthing automatic installer"
rootCheck


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}setup-if-stale.sh" ]; then
  "${WSU_DIR}setup-if-stale.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


# Add the release PGP keys:
rm -f /usr/share/keyrings/*syncthing*
curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg


# Add the "stable" channel to your APT sources:
rm -f /etc/apt/sources.list.d/*syncthing*
cat <<EOF | sudo tee /etc/apt/sources.list.d/webstackup-syncthing.sources
Types: deb
URIs: https://apt.syncthing.net/
Suites: syncthing
Components: stable-v2
Signed-By: /usr/share/keyrings/syncthing-archive-keyring.gpg
EOF


# Update and install syncthing:
fxAptUpdate 0
wsuAptPin syncthing
sudo apt-get install apt-transport-https ca-certificates syncthing -y

# https://docs.syncthing.net/users/autostart.html#how-to-set-up-a-system-service
systemctl daemon-reload
systemctl enable syncthing@$(logname).service
systemctl start syncthing@$(logname).service

#
fxTitle "Add this to your .ssh/config profile"
echo "# syncthing http://localhost:5555/"
echo "LocalForward 5555 localhost:8384"
fxMessage "🏁 http://localhost:5555/"

fxEndFooter
