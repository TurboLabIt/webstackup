#!/usr/bin/env bash
### AUTOMATIC www-data GENERATOR BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/account/generate-www-data.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/generate-www-data.sh?$(date +%s) | sudo bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🕸 www-data generator"
rootCheck


fxTitle "👨‍👩‍👧‍👧 Generating www-data (the group)..."
if ! getent group "www-data" &>/dev/null; then
  groupadd --system www-data
else
  fxInfo "www-data group already exists, skipping"  
fi


fxTitle "👨‍🏭 Generating www-data (the user)..."
if ! id "www-data" &>/dev/null; then
  useradd www-data -g www-data --shell=/usr/sbin/nologin --create-home --system
else
  fxInfo "www-data already exists, skipping"  
fi

groups www-data
id www-data
grep -i www-data /etc/passwd


fxTitle "👨‍🏭 Generating webstackup (the user)..."
if ! id "webstackup" &>/dev/null; then

  useradd webstackup -g www-data --shell=/usr/sbin/nologin --create-home --system
  
  fxTitle "🔐 Generating SSH key for webstackup..."
  mkdir /home/webstackup/.ssh
  chown webstackup:www-data /home/webstackup/.ssh
  chmod u=rwx,go= /home/webstackup/.ssh
  sudo -u webstackup -H ssh-keygen -t rsa -N "" -C "webstackup on $(hostname) by generate-www-data.sh" -f /home/webstackup/.ssh/id_rsa
  
else

  fxInfo "webstackup already exists, skipping"  
fi

groups webstackup
id webstackup
grep -i webstackup /etc/passwd


function wwwdataOwner()
{
  fxTitle "Setting the owner to www-data on ##$1##..."
  chown www-data:www-data "$1" -R
  chmod ugo= "$1" -R
  chmod u=rwX,g=rX,o= "$1" -R
  # SetGID - Any new file will have its group set to www-data
  chmod g+s "$1"
}


fxTitle "🏡 Creating /home/www-data/..."
if [ ! -d /home/www-data ]; then

  mkdir -p /home/www-data
  wwwdataOwner /home/www-data/
  
else

  fxInfo "/home/www-data/ already exists, skipping"
fi

ls -lah /home/www-data


fxTitle "📂 Creating /var/www/..."
if [ ! -d /var/www ]; then

  mkdir -p /var/www
  chown webstackup:www-data /var/www/ -R
  chmod ugo= /var/www/ -R
  chmod u=rwX,g=rX,o= /var/www/ -R
  # SetGID - Any new file will have its group set to www-data
  chmod g+s /var/www/
  
else

  fxInfo "/var/www/ already exists, skipping"
fi

ls -lah /var/www/


fxTitle "🚛 Moving www-data stuff from /var/www the home..."
function wwwdataFileMover()
{
  local ORIG_PATH=/var/www/$1
  local DEST_PATH=/home/www-data/
  
  fxMessage "##${ORIG_PATH}## ✈ ##${DEST_PATH}##"
  if [ -e "${ORIG_PATH}" ]; then
  
    rm -rf "${DEST_PATH}$1"
    mv "${ORIG_PATH}" "${DEST_PATH}"
    
  else
  
    fxInfo "File doesn't exists, skipping"
  fi
}

wwwdataFileMover .bash_history
wwwdataFileMover .bash_logout
wwwdataFileMover .bashrc
wwwdataFileMover .cache
wwwdataFileMover .profile
wwwdataFileMover .ssh
wwwdataFileMover .sudo_as_admin_successful

wwwdataOwner /home/www-data/


fxEndFooter
