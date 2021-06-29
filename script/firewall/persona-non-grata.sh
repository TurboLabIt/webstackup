#!/bin/bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "🛡️ persona-non-grata"
rootCheck

printMessage "Removing previous rules and disable the firewall..."
sudo ufw --force reset

printMessage "🐧 Allow SSH..."
ufw allow 22/tcp

printMessage "💌 Allow SMTP..."
ufw allow 25/tcp

printMessage "🌎 Allow HTTP(s)..."
ufw allow 80,443/tcp

printMessage "🔥🔥 Shields up! Activating the firewall..."
ufw --force enable 
ufw status

printMessage "🧹 Removing backup file..."
sudo rm -f /etc/ufw/user.rules.* /etc/ufw/before.rules.* /etc/ufw/after.rules.*
sudo rm -f /etc/ufw/user6.rules.* /etc/ufw/before6.rules.* /etc/ufw/after6.rules.*

printMessage "persona-non-grata is done"
