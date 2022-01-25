#!/usr/bin/env bash
### AUTOMATIC ELASTICSEARCH INSTALL BY WEBSTACK.UP

if ! [ $(id -u) = 0 ]; then

    echo "This script must run as ROOT"
    exit
fi

echo -e "\e[1;45m Removing previous version (if any) \e[0m"
apt purge --auto-remove elasticsearch* -y -qq

echo -e "\e[1;45m Setting up the repo... \e[0m"
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

echo -e "\e[1;45m Installing... \e[0m"
apt update -qq
apt install elasticsearch -y -qq

echo -e "\e[1;45m Binding to localhost only... \e[0m"

systemctl enable elasticsearch
service elasticsearch restart
systemctl --no-pager status elasticsearch
