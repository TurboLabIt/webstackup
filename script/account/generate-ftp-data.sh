#!/usr/bin/env bash
### AUTOMATIC ftp-data GENERATOR BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/account/generate-ftp-data.sh
#
# The system user the Pure-FTPd virtual users are mapped on
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/generate-ftp-data.sh | sudo bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📂 ftp-data generator"
rootCheck


fxTitle "👨‍👩‍👧‍👧 Checking www-data (the group)..."
if ! getent group "www-data" &>/dev/null; then
  groupadd --system www-data
else
  fxInfo "www-data group already exists, skipping 🦘"
fi


fxTitle "👨‍🏭 Generating ftp-data (the user)..."
if ! id "ftp-data" &>/dev/null; then
  useradd ftp-data -g www-data --shell=/usr/sbin/nologin --home-dir /home/ftp-data --create-home --system
else
  fxInfo "ftp-data already exists, skipping 🦘"
fi


fxTitle "🏡 Creating /home/ftp-data/..."
if [ ! -d /home/ftp-data ]; then
  mkdir -p /home/ftp-data
else
  fxInfo "/home/ftp-data/ already exists, skipping 🦘"
fi

chown ftp-data:www-data /home/ftp-data

groups ftp-data
id ftp-data
grep -i ftp-data /etc/passwd


fxEndFooter
