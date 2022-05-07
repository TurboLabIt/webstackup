#!/usr/bin/env bash
### FIREWALL FACTORY RESET BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/firewall/iptables-reset.sh?$(date +%s) | sudo bash
# 

echo ""
echo -e "\e[1;46m ==================== \e[0m"
echo -e "\e[1;46m ❤️‍🩹 FIREWALL RESET \e[0m"
echo -e "\e[1;46m ==================== \e[0m"

if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi


echo -e "\e[1;33m Checking UFW... \e[0m"
if [ -z "$(command -v ufw)" ]; then

  echo -e "\e[1;32m ✔ ufw is not installed \e[0m"
  UFW_INACTIVE=1
  
else

  ufw status | grep -qw active
  UFW_INACTIVE=$?
fi
  
if [ $UFW_INACTIVE != 1 ]; then

  echo -e "\e[1;33m "Disabling UFW... \e[0m"
  ufw --force reset
  ufw disable
  
fi


echo -e "\e[1;33m ACCEPT everything... \e[0m"
iptables -P INPUT ACCEPT

echo -e "\e[1;33m Clearing the rules... \e[0m"
iptables -F

echo -e "\e[1;33m Saving... \e[0m"

echo -e "\e[1;32m ✔ Firewall reset completed! \e[0m"
