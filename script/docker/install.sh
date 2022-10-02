#!/usr/bin/env bash
### AUTOMATIC DOCKER INSTALL BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/docker/install.sh?$(date +%s) | sudo bash

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Docker installer"
rootCheck

## Source (with some tweaks): https://docs.docker.com/engine/install/ubuntu/


fxTitle "Installing additional prerequisites..."
apt update -qq
apt install apt-transport-https software-properties-common -y


fxTitle "Installing Nginx prerequisites from docs..."
apt install ca-certificates curl gnupg lsb-release -y


fxTitle "Add Docker official GPG key..."
rm -f /etc/apt/trusted.gpg.d/webstackup.docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/webstackup.docker.gpg


fxTitle "Set up the repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/webstackup.docker.list > /dev/null

apt update -qq
apt-cache policy docker-ce


fxTitle "Install Docker Engine..."
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


fxTitle "Enable auto-start..."
systemctl enable docker


fxTitle "Restarting the service..."
service docker restart


fxTitle "Pre-download some image..."
# https://hub.docker.com/_/ubuntu
docker pull ubuntu
# https://hub.docker.com/_/alpine
docker pull alpine
docker images


fxTitle "Run a Docker test image..."
docker run --name 'webstackup-setup-test' docker/whalesay cowsay "Docker has been installed via Webstackup!"


fxTitle "Remove the test..."
docker container rm 'webstackup-setup-test'
docker image rm docker/whalesay


fxEndFooter
