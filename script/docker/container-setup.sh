#!/usr/bin/env bash
### AUTOMATIC DOCKER CONTAINER SETUP BY WEBSTACK.UP
# apt update && apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/docker/container-setup.sh?$(date +%s) | bash

if ! [ $(id -u) = 0 ]; then

    echo "This script must run as ROOT"
    exit
fi

apt install sudo wget nano -y
apt dist-upgrade -y
apt autoremove -y
