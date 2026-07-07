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
DOCKER_GPG_FILE=/usr/share/keyrings/docker.asc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "${DOCKER_GPG_FILE}"
chmod a+r "${DOCKER_GPG_FILE}"
# globally-trusted location used by previous versions of this script
rm -f /etc/apt/trusted.gpg.d/webstackup.docker.gpg


fxTitle "Set up the repository..."
tee /etc/apt/sources.list.d/webstackup-docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(lsb_release -cs)
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: ${DOCKER_GPG_FILE}
EOF

# legacy one-line format used by previous versions of this script
rm -f /etc/apt/sources.list.d/webstackup.docker.list /etc/apt/sources.list.d/webstackup.docker.list.bak

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
curl -o /tmp/dockerfile-isolated-ssh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/docker/dockerfile-isolated-ssh
docker build --network host -t wsu-ssh -f /tmp/dockerfile-isolated-ssh .
# docker run -td --name=user-name -p 30987:22 wsu-ssh
# zzdock attach user-name


fxTitle "Run a Docker test image..."
# cowsay is only packaged in Alpine's edge/testing repo
docker run --network host --name 'webstackup-setup-test' alpine sh -c \
  'apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ cowsay > /dev/null && cowsay "Docker has been installed via Webstackup!"'


fxTitle "Remove the test..."
docker container rm 'webstackup-setup-test'


fxEndFooter
