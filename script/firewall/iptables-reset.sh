#!/usr/bin/env bash
### FIREWALL FACTORY RESET BY WEBSTACKUP
# clear && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/firewall/iptables-reset.sh?$(date +%s) | sudo bash

echo ""
echo -e "\e[1;46m ==================== \e[0m"
echo -e "\e[1;46m ❤️‍🩹 FIREWALL RESET \e[0m"
echo -e "\e[1;46m ==================== \e[0m"

if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi


echo -e "\e[1;33m Checking ufw... \e[0m"
if [ -z "$(command -v ufw)" ]; then

  echo -e "\e[1;32m ✔ ufw is not installed \e[0m"
  UFW_INACTIVE=1
  
else

  ufw status | grep -qw active
  UFW_INACTIVE=$?
fi
  
if [ $UFW_INACTIVE != 1 ]; then

  echo -e "\e[1;33m Disabling ufw... \e[0m"
  ufw --force reset
  ufw disable
  
else 
  
  echo -e "\e[1;32m ✔ ufw is not enabled \e[0m"
fi


echo -e "\e[1;33m Accept all traffic first to avoid ssh lockdown via iptables firewall rules... \e[0m"
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
 
echo -e "\e[1;33m Flush all iptables chains/firewall rules... \e[0m"
iptables -F
 
echo -e "\e[1;33m Delete all iptables chains... \e[0m"
iptables -X
 
echo -e "\e[1;33m Flush all counters too... \e[0m"
iptables -Z 

echo -e "\e[1;33m Flush and delete all NAT and mangle... \e[0m"
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X

echo -e "\e[1;33m Saving... \e[0m"

echo -e "\e[1;32m ✔ Firewall reset completed! \e[0m"
