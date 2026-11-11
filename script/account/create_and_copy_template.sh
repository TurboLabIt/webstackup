#!/usr/bin/env bash
### AUTOMATIC LINUX USER ACCOUNT PROVISIONING INSTALL BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/account/create_and_copy_template.sh
#
# One sub-folder per account: the folder name is the username, its content is copied into the home
# https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/ssh-accounts/readme.md
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/create_and_copy_template.sh | sudo bash -s -- "/my-path/accounts"

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "👥 Create Linux users from a template"
rootCheck


## remove the trailing "/"
USERS_ORIGIN=${1%*/}
if [ -z "${USERS_ORIGIN}" ] || [ ! -d "${USERS_ORIGIN}" ] || [ -z "$(ls -A "${USERS_ORIGIN}")" ]; then
  fxCatastrophicError "User origin ##${USERS_ORIGIN}## is empty!"
fi

fxInfo "Accounts from ##${USERS_ORIGIN}##"


GROUPNAME=devops
fxTitle "👨‍👩‍👧‍👧 Checking the ${GROUPNAME} group..."
if ! getent group "${GROUPNAME}" &>/dev/null; then
  groupadd "${GROUPNAME}"
else
  fxInfo "${GROUPNAME} group already exists, skipping 🦘"
fi


## no sub-folders = no iterations (the unmatched pattern would become a username)
shopt -s nullglob
for DIR in "${USERS_ORIGIN}"/*/; do

  ## remove the trailing "/"
  DIR=${DIR%*/}
  ## the last directory name
  USERNAME=${DIR##*/}

  fxTitle "👤 ${USERNAME}"

  if ! id "${USERNAME}" &>/dev/null; then

    fxMessage "👨‍🏭 Creating ${USERNAME}..."
    if ! useradd "${USERNAME}" --create-home -s /bin/bash -g "${GROUPNAME}" -G sudo,www-data; then

      ## no home to copy into, and an invalid name would break /etc/sudoers
      fxWarning "Cannot create ${USERNAME}, skipping it"
      continue
    fi

  else

    fxInfo "${USERNAME} already exists, not creating it 🦘"
  fi

  fxMessage "📋 Copying ${USERNAME} data from origin..."
  \cp -r "${DIR}/." "/home/${USERNAME}"

  ## only the home itself and what was just copied, never the whole home recursively: every deploy runs this,
  ## and it re-owned everything the user keeps there (e.g. rootless Docker's data, in group devops: no container starts)
  fxMessage "👮 Fixing owning and permissions of /home/${USERNAME} and the copied files..."
  chown "${USERNAME}:${GROUPNAME}" "/home/${USERNAME}/"
  chmod u=rwx,g=rx,o= "/home/${USERNAME}/"
  find "${DIR}" -mindepth 1 -printf '%P\0' | while IFS= read -r -d '' ITEM; do

    chown -h "${USERNAME}:${GROUPNAME}" "/home/${USERNAME}/${ITEM}"
    if [ ! -L "/home/${USERNAME}/${ITEM}" ]; then
      chmod u=rwx,g=rx,o= "/home/${USERNAME}/${ITEM}"
    fi
  done

  if [ -d "/home/${USERNAME}/.ssh" ]; then
    fxSshResetUserSshPermissions "${USERNAME}"
  fi

  fxMessage "🦸 Checking if ${USERNAME} is allowed to sudo without password..."
  if grep -q "${USERNAME} ALL" /etc/sudoers; then

    fxInfo "${USERNAME} already allowed, skipping 🦘"

  else

    ## https://turbolab.it/1301
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    fxOK "${USERNAME} allowed"
  fi

done


fxEndFooter
