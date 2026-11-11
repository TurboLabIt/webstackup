#!/usr/bin/env bash
### AUTOMATIC LINUX USER ACCOUNT PROVISIONING INSTALL BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/edit/master/script/account/create_and_copy_template.sh

echo ""
echo -e "\e[1;46m =============== \e[0m"
echo -e "\e[1;46m CREATE ACCOUNTS \e[0m"
echo -e "\e[1;46m =============== \e[0m"

if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi

USERS_ORIGIN=$1
# remove the trailing "/"
USERS_ORIGIN=${USERS_ORIGIN%*/}
if [ -z $1 ] || [ ! -d ${USERS_ORIGIN} ] || [ -z "$(ls -A ${USERS_ORIGIN})" ]; then

  echo ""
  echo -e "\e[1;41m User origin ##${USERS_ORIGIN}## is empty! \e[0m"
  exit
  
fi


GROUPNAME=devops
echo -e "\e[1;45m Checking group name ${GROUPNAME}... \e[0m"
echo ""
if [ $(getent group $GROUPNAME) ]; then

  echo -e "\e[1;42m Group $GROUPNAME already exists \e[0m"
  
else

  echo -e "\e[1;43m Creating group $GROUPNAME... \e[0m"
  groupadd devops
fi


echo ""
echo -e "\e[1;45m Iterating over ${USERS_ORIGIN}... \e[0m"
for dir in ${USERS_ORIGIN}/*/
do
  # remove the trailing "/"
  DIR=${dir%*/}

  # get the last directory name
  USERNAME="${DIR##*/}"

  echo ""
  echo -e "\e[1;45m *** ${USERNAME} *** \e[0m"

  if id "$USERNAME" &>/dev/null; then

    echo -e "\e[1;42m $USERNAME already exists \e[0m"

  else

    echo -e "\e[1;43m Creating $USERNAME... \e[0m"
    useradd ${USERNAME} --create-home -s /bin/bash -g devops -G sudo,www-data
  fi

  echo -e "\e[1;45m Copying ${USERNAME} data from origin... \e[0m"
  \cp -r ${DIR}/. /home/$USERNAME

  ## only the home itself and what was just copied, never the whole home recursively: every deploy runs this,
  ## and it re-owned everything the user keeps there (e.g. rootless Docker's data, in group devops: no container starts)
  echo -e "\e[1;45m Fixing owning and permissions of /home/${USERNAME} and the copied files... \e[0m"
  chown ${USERNAME}:${GROUPNAME} /home/$USERNAME/
  chmod u=rwx,g=rx,o=  /home/$USERNAME/
  find "${DIR}" -mindepth 1 -printf '%P\0' | while IFS= read -r -d '' ITEM; do

    chown -h ${USERNAME}:${GROUPNAME} "/home/${USERNAME}/${ITEM}"
    if [ ! -L "/home/${USERNAME}/${ITEM}" ]; then
      chmod u=rwx,g=rx,o= "/home/${USERNAME}/${ITEM}"
    fi
  done

  echo -e "\e[1;45m Fixing /home/${USERNAME}/.ssh permissions... \e[0m"
  chmod u=rwx,go=  /home/$USERNAME/.ssh -R

  echo -e "\e[1;45m Checking if $USERNAME is allowed to sudo without password... \e[0m"
  SUDO_SEARCH="$USERNAME ALL"

  if grep -q "$SUDO_SEARCH" /etc/sudoers; then

    echo -e "\e[1;42m $USERNAME already allowed \e[0m"

  else

    echo -e "\e[1;43m Allowing $USERNAME... \e[0m"
    # https://turbolab.it/1301
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  fi

done

echo ""
echo -e "\e[1;42m DONE! \e[0m"
