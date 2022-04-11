### CHANGE MOTD ON UBUNTU BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/filesystem/motd.sh?$(date +%s) | sudo bash
#!/usr/bin/env bash

## Disable dynamic news ( https://motd.ubuntu.com/ )
##
sudo sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
sudo cat /etc/default/motd-news | grep 'ENABLED='

## Disable "Welcome to Ubuntu"
sudo chmod -x /etc/update-motd.d/00-header

## Disable support links
sudo chmod -x /etc/update-motd.d/10-help-text

## Disable "XX updates can be applied immediately"
sudo chmod -x /etc/update-motd.d/90-updates-available

## Add hostname
if [ ! -f /etc/update-motd.d/00-webstackup-hostname ] && [ -f /usr/local/turbolab.it/webstackup/script/filesystem/hostname.sh ]; then

 ln -s /usr/local/turbolab.it/webstackup/script/filesystem/hostname.sh /etc/update-motd.d/00-webstackup-hostname
 
elif [ ! -f /etc/update-motd.d/00-webstackup-hostname ] && [ ! -f /usr/local/turbolab.it/webstackup/script/filesystem/hostname.sh ]; then

  sudo curl -Lo /etc/update-motd.d/00-webstackup-hostname https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/filesystem/hostname.sh?$(date +%s)
 
fi
