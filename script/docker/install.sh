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

## Source: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04
## Add. source: https://docs.docker.com/engine/install/ubuntu/


fxTitle "Install a few prerequisite packages..."
apt update -qq
apt install apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release -y


fxTitle "Add Docker official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -


fxTitle "Set up the repository..."
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -sc) stable"
apt update -qq
apt-cache policy docker-ce
exit

fxTitle "Installing Docker..."
apt install docker-ce -y


fxTitle "Enable auto-start..."
systemctl enable docker


fxTitle "Restarting the service..."
service docker restart

exit
fxEndFooter





## Download Ubuntu
docker pull ubuntu
docker images

##
curl -o dockerfile https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/docker/dockerfile?$(date +%s)
docker build -t webstackup:latest .
docker run -td --name=ws1 -p 802:80 -p 4432:443 -p 222:22 webstackup

## 
echo "vvvvvvvvvvvvvvvvvvvvvvvv"
echo "docker exec -it ws1 bash"
echo "^^^^^^^^^^^^^^^^^^^^^^^^"
