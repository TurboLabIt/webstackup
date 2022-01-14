#!/bin/bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "❤️‍🩹 iptables-reset"
rootCheck

printMessage "ACCEPT everything..."
iptables -P INPUT ACCEPT

printMessage "Clearing the rules..."
iptables -F

printMessage "Saving..."

printMessage "iptables-reset is done"
