#!/usr/bin/env bash
### AUTOMATIC DOCKER INSTALL BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/docker/install.sh | sudo bash

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


fxTitle "Installing Docker prerequisites from docs..."
apt install ca-certificates curl gnupg lsb-release -y


fxTitle "Add Docker official GPG key..."
DOCKER_GPG_FILE=/etc/apt/trusted.gpg.d/webstackup.docker.gpg
rm -f "${DOCKER_GPG_FILE}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o "${DOCKER_GPG_FILE}"


fxTitle "Set up the repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=${DOCKER_GPG_FILE}] https://download.docker.com/linux/ubuntu \
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


fxTitle "Prepare wsu-ssh Docker image..."
curl -o /tmp/dockerfile-isolated-ssh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/docker/dockerfile-isolated-ssh?$(date +%s)
docker build --network host -t wsu-ssh -f /tmp/dockerfile-isolated-ssh .
# docker run -td --name=user-name -p 30987:22 wsu-ssh
# zzdock attach user-name


fxTitle "Run a Docker test image..."
docker run --name 'webstackup-setup-test' docker/whalesay cowsay "Docker has been installed via Webstackup!"


fxTitle "Remove the test..."
docker container rm 'webstackup-setup-test'
docker image rm docker/whalesay


fxEndFooter
