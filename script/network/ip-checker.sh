#!/usr/bin/env bash
### IP CHECKER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/network/ip-checker.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/network/ip-checker.sh | bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🗺️ IP checker"

fxTitle "📃 IPs to check"
while [ -z "$WSU_IP_LIST" ]; do

  echo "🤖 Provide the list of IP to check, one per line. Hit Ctrl+D when done"
  WSU_IP_LIST=$(cat < /dev/tty)
done

fxTitle "🔍 Checking..."
IP_CHECKED=0
IP_INVALID=0
IP_OK=0
IP_KO=0

while IFS= read -r line; do

  # Cleanup: remove everything that is not a number or a dot
  IP=$(echo "$line" | tr -cd '0-9.')

  # Check if the trimmed line is empty; if so, skip it silently
  if [ -z "$IP" ]; then
    continue
  fi

  fxTitle "$IP"
  whois "$IP" | egrep -i 'Organization:|OrgName:|City:|Country:' | head -n 5
  echo ""

done <<< "$WSU_IP_LIST"


fxTitle "📊 Report"
#echo "Invalid IPs : $IP_INVALID"
echo "Checked IPs : $IP_CHECKED"
#echo ""
#echo "OK IPs      : $IP_OK"
#echo "KO IPs      : $IP_KO"

fxEndFooter
