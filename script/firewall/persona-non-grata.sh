#!/bin/bash
echo ""

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "🛡️ persona-non-grata"
rootCheck


printTitle "📦 Checking packages...."
if [ -z "$(command -v curl)" ] || [ -z "$(command -v iptables)" ] || [ -z "$(command -v ipset)" ]; then

  printMessage "Installing packages..."
  apt update
  apt install iptables ipset curl -y
  
else

  printMessage "✔ iptables and ipset are already installed"
fi


printTitle "🧹 Clear the log file..."
mkdir -p "${WEBSTACKUP_AUTOGENERATED_DIR}"
PNG_IP_LOG_FILE=${WEBSTACKUP_AUTOGENERATED_DIR}persona-non-grata.log
date +"%Y-%m-%d %T" > "${PNG_IP_LOG_FILE}"


printTitle "⏬ Downloading IP block list..."
IP_BLACKLIST_FULLPATH=${WEBSTACKUP_AUTOGENERATED_DIR}persona-non-grata.txt
curl -Lo "${IP_BLACKLIST_FULLPATH}" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/firewall/persona-non-grata.txt
echo "" >> $IP_BLACKLIST_FULLPATH

printTitle "⏬ Appending http://iplists.firehol.org/ ..."
echo "## http://iplists.firehol.org/" >> $IP_BLACKLIST_FULLPATH
curl https://raw.githubusercontent.com/ktsaou/blocklist-ipsets/master/firehol_level1.netset >> $IP_BLACKLIST_FULLPATH
echo "" >> $IP_BLACKLIST_FULLPATH

printTitle "⏬ Appending https://github.com/stamparm/ipsum ..."
echo "## https://github.com/stamparm/ipsum" >> $IP_BLACKLIST_FULLPATH
curl --compressed https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt 2>/dev/null | grep -v "#" | grep -v -E "\s[1-2]$" | cut -f 1 >> $IP_BLACKLIST_FULLPATH


printTitle "Checking ufw...."
if [ -z "$(command -v ufw)" ]; then

  printMessage "✔ ufw is not installed"
  UFW_INACTIVE=1
  
else

  ufw status | grep -qw active
  UFW_INACTIVE=$?
fi
  
if [ $UFW_INACTIVE != 1 ]; then

  printMessage "Disabling ufw..."
  ufw --force reset
  ufw disable
  
else 
  
  printMessage "✔ ufw is not enabled"
fi


printTitle "🧹 Try to uninstall iptables-persistent..."
apt purge iptables-persistent -y


printTitle "🧹 Reset iptables..."
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -F
ip6tables -X


printTitle "🧹 Cleaning up previous persona-non-grata ipset set..."
ipset destroy PersonaNonGrata

printTitle "☀ Creating new persona-non-grata ipset set..."
ipset create PersonaNonGrata nethash

printTitle "🧱 Building ipset from file..."
while read -r line || [[ -n "$line" ]]; do
  FIRSTCHAR="${line:0:1}"
  if [ "$FIRSTCHAR" != "#" ] && [ "$FIRSTCHAR" != "" ]; then
    echo "Add: $line" >> "${PNG_IP_LOG_FILE}"
    ipset add PersonaNonGrata $line
  fi  
done < "$IP_BLACKLIST_FULLPATH"


printTitle "🚪 Creating iptables rules..."

printMessage "🏡 Allow from localhost..."
iptables -A INPUT -i lo -j ACCEPT

printMessage "🏡 Allow connections from LAN..."
iptables -A INPUT -s 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16 -j ACCEPT

printMessage "🛑 Enable ipset blocklist..."
iptables -A INPUT -m set --match-set PersonaNonGrata src -j DROP

printMessage "📤 Allow ESTABLISHED,RELATED..."
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

printMessage "🐧 Allow SSH..."
iptables -A INPUT -p tcp -m multiport --dport 22,222 -j ACCEPT

printMessage "📁 Allow FTP/FTPS"
iptables -A INPUT -p tcp -m multiport --dport 20,21,990,2121:2221 -j ACCEPT

printMessage "💌 Allow SMTP..."
iptables -A INPUT -p tcp --dport 25 -j ACCEPT

printMessage "🌎 Allow HTTP(s)..."
iptables -A INPUT -p tcp -m multiport --dport 80,443 -j ACCEPT

printMessage "🛑 Drop everything else..."
iptables -A INPUT -j DROP


printTitle "🍃 Looking for pure-ftpd..."
if [ -f /etc/pure-ftpd/conf/PassivePortRange ]; then
  
  printMessage "pure-ftpd found! Updating PassivePortRange..."
  ln -s ${WEBSTACKUP_CONFIG_DIR}ftp/PassivePortRange /etc/pure-ftpd/conf/PassivePortRange
  
else 
  printMessage "pure-ftpd not found. No PassivePortRange updated."
fi

printTitle "✅ persona-non-grata is done"
printMessage "iptables"
iptables -nvL

printMessage "ipset"
ipset list PersonaNonGrata | head -n 7
echo "...."

printTitle "Need the log?"
printMessage "nano ${PNG_IP_LOG_FILE}"
