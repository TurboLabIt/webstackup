#!/usr/bin/env bash
### AUTOMATIC SYNCTHING INSTALL BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/syncthing/install.sh?$(date +%s) | sudo bash
#

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🔄 Syncthing automatic installer"
rootCheck

## https://apt.syncthing.net/ ##
################################

# Add the release PGP keys:
curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

# Add the "stable" channel to your APT sources:
echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

# Increase preference of Syncthing's packages ("pinning")
printf "Package: *\nPin: origin apt.syncthing.net\nPin-Priority: 990\n" | sudo tee /etc/apt/preferences.d/syncthing

# Update and install syncthing:
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates syncthing -y

# https://docs.syncthing.net/users/autostart.html#how-to-set-up-a-system-service
systemctl enable syncthing@$(logname).service
systemctl start syncthing@$(logname).service

fxEndFooter
