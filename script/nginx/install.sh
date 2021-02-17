#!/bin/bash

if ! [ $(id -u) = 0 ]; then

    echo "This script must run as ROOT"
    exit
fi
  
## Add Nginx key and repo
apt update
apt install curl gnupg2 ca-certificates lsb-release unzip nano -y
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list
echo "deb-src [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list.d/nginx.list
	
## Pinning the repo
NGINX_PINNING_FILE=/etc/apt/preferences.d/99-nginx-webstackup
echo "Package: nginx" > $NGINX_PINNING_FILE
echo -n "Pin: release a=" >> $NGINX_PINNING_FILE
echo "$(lsb_release -sc)" >> $NGINX_PINNING_FILE
echo "Pin-Priority: -900" >> $NGINX_PINNING_FILE
	
## Install Nginx
apt update -qq
apt install nginx -y

## Start the service
systemctl restart nginx
