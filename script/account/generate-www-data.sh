#!/usr/bin/env bash
### AUTOMATIC www-data GENERATOR BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/account/generate-www-data.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/generate-www-data.sh?$(date +%s) | sudo bash

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
  useradd -G www-data www-data --shell=/bin/false --create-home --system
else
  fxInfo "www-data already exists, skipping"  
fi

id www-data
echo "---"
groups www-data
echo "---"
grep -i www-data /etc/passwd


function wwwdataOwner()
{
  fxTitle "Setting the owner to www-data:www-data..."
  chown www-data:www-data "$1" -R
  chmod u=rwX,g=rX,o= "$1" -R
  # SetGID - Any new file will have its group set to www-data
  chmod g+s "$1"
}


fxTitle "🏡 Creating /home/www-data/..."
if [ ! -d /home/www-data ]; then

  mkdir -p /home/www-data
  wwwdataOwner /home/www-data
  
else
  fxInfo " /home/www-data/ already exists, skipping"
fi

ls -lh /home/www-data/


fxTitle "📂 Creating /var/www/..."
if [ ! -d /var/www ]; then

  mkdir -p /var/www
  wwwdataOwner /var/www
  
else

  fxInfo "/var/www/ already exists, skipping"
fi

ls -lh /var/www/


fxTitle "🚛 Moving www-data stuff to the new home..."
function wwwdataFileMover()
{
  local FILE_TO_MOVE=$1
  fxMessage "##${ORIG_PATH}## ✈ ##${DEST_PATH}##"
  if [ -e "/var/www/$FILE_TO_MOVE" ]; then
  
    rm -rf "/home/www-data/$FILE_TO_MOVE"
    mv "/var/www/$FILE_TO_MOVE" "/home/www-data/"
    wwwdataOwner "/home/www-data/$FILE_TO_MOVE"
    fxOK "Done"
    
  else
  
    fxInfo "File doesn't exists, skipping"
  fi
}

wwwdataFileMover bash_history
wwwdataFileMover .bash_logout
wwwdataFileMover .bashrc
wwwdataFileMover .cache
wwwdataFileMover .profile
wwwdataFileMover .ssh
wwwdataFileMover .sudo_as_admin_successful


fxTitle "👮‍♂️ Resetting permissions on /home/www-data/..."
chown www-data:www-data /home/www-data/ -R
chmod ugo= /home/www-data -R
chmod u=rwx,g=rX,o= /home/www-data -R


fxTitle "🏢 Generating .ssh for www-data..."
if [ ! -d /home/www-data/.ssh ]; then

  ssh-keygen -t rsa -N "" -C "www-data key generated on $(hostname) by generate-www-data.sh" -f /home/www-data/.ssh/id_rsa
  
else

  fxInfo "/home/www-data/.ssh already exists, skipping"
fi


fxTitle "🩹 Ensuring .ssh has the right permissions..."
# https://superuser.com/a/215506/129204
chmod u=rwx,go= /home/www-data/.ssh -R
chmod u=rw,go=r /home/www-data/.ssh/id_rsa.pub
chmod u=rw,go= /home/www-data/.ssh/id_rsa


fxTitle "🔐 Removing authorized_keys from www-data..."
rm -f /home/www-data/.ssh/authorized_keys


fxEndFooter
