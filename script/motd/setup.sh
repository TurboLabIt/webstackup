#!/usr/bin/env bash
### CHANGE MOTD ON UBUNTU BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/motd/setup.sh?$(date +%s) | sudo bash
#

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💡 Message of the day setup"
rootCheck

function disableExec()
{
  if [ -f "$1" ]; then
    chmod -x "$1"
  fi
}

## Disable dynamic news ( https://motd.ubuntu.com/ )
if [ -f "/etc/default/motd-news" ]; then
  sudo sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
fi

## Disable "Welcome to Ubuntu"
disableExec /etc/update-motd.d/00-header

## Disable support links
disableExec /etc/update-motd.d/10-help-text

## Disable "This system has been minimized"
disableExec /etc/update-motd.d/60-unminimize

## Disable "XX updates can be applied immediately"
disableExec /etc/update-motd.d/90-updates-available

## Disable "Introducing Expanded Security Maintenance for Applications"
disableExec 88-esm-announce
disableExec 91-contract-ua-esm-status

## Add hostname
if [ -z "$(command -v figlet)" ] || [ ! -f "/usr/games/lolcat" ]; then
  sudo apt install figlet lolcat -y -qq
fi

if [ ! -f /etc/update-motd.d/00-webstackup-hostname ] && [ -f /usr/local/turbolab.it/webstackup/script/motd/hostname-banner.sh ]; then

 ln -s /usr/local/turbolab.it/webstackup/script/motd/hostname-banner.sh /etc/update-motd.d/00-webstackup-hostname
 
elif [ ! -f /etc/update-motd.d/00-webstackup-hostname ] && [ ! -f /usr/local/turbolab.it/webstackup/script/motd/hostname-banner.sh ]; then

  sudo curl -Lo /etc/update-motd.d/00-webstackup-hostname https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/motd/hostname-banner.sh?$(date +%s)
  sudo chmod u=rwx,go=rx /etc/update-motd.d/00-webstackup-hostname
fi

bash "/etc/update-motd.d/00-webstackup-hostname"

fxEndFooter
