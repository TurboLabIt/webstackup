
#!/usr/bin/env bash
### AUTOMATIC DOCKER INSTALL BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/docker/install.sh?$(date +%s) | sudo bash


if ! [ $(id -u) = 0 ]; then

    echo "This script must run as ROOT"
    exit
fi


## Add Docker key and repo
apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -sc) stable"

## Pinning the repo
DOCKER_PINNING_FILE=/etc/apt/preferences.d/99-docker-webstackup
#echo "Package: docker-ce" > $DOCKER_PINNING_FILE
#echo -n "Pin: release a=" >> $DOCKER_PINNING_FILE
#echo "$(lsb_release -sc)" >> $DOCKER_PINNING_FILE
#echo "Pin-Priority: -900" >> $DOCKER_PINNING_FILE

apt update -qq
apt-cache policy docker-ce

## Install Docker
apt install docker-ce -y

## Download Ubuntu
docker pull ubuntu
docker images

## Istantiate one Ubuntu container
echo "docker run -it --name=ws1 -p 802:80 -p 4432:443 -p 222:22 ubuntu"
