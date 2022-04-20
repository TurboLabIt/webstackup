#!/usr/bin/env bash
### CHANGE MOTD ON UBUNTU BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/filesystem/motd.sh?$(date +%s) | sudo bash
#

echo ""
echo -e "\e[1;46m ========== \e[0m"
echo -e "\e[1;46m MOTD SETUP \e[0m"
echo -e "\e[1;46m ========== \e[0m"

if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi

## Disable dynamic news ( https://motd.ubuntu.com/ )
sudo sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news

## Disable "Welcome to Ubuntu"
sudo chmod -x /etc/update-motd.d/00-header

## Disable support links
sudo chmod -x /etc/update-motd.d/10-help-text

## Disable "XX updates can be applied immediately"
sudo chmod -x /etc/update-motd.d/90-updates-available

## Add hostname
if [ ! -f /etc/update-motd.d/00-webstackup-hostname ] && [ -f /usr/local/turbolab.it/webstackup/script/filesystem/hostname-banner.sh ]; then

 ln -s /usr/local/turbolab.it/webstackup/script/filesystem/hostname-banner.sh /etc/update-motd.d/00-webstackup-hostname
 
elif [ ! -f /etc/update-motd.d/00-webstackup-hostname ] && [ ! -f /usr/local/turbolab.it/webstackup/script/filesystem/hostname-banner.sh ]; then

  sudo curl -Lo /etc/update-motd.d/00-webstackup-hostname https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/filesystem/hostname-banner.sh?$(date +%s)
  sudo chmod u=rwx,go=rx /etc/update-motd.d/00-webstackup-hostname
  
fi

bash "/etc/update-motd.d/00-webstackup-hostname"
