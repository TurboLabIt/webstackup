#!/usr/bin/env bash
### LINUX USERS ACCOUNT REMOVER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/account/delete-users.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/delete-users.sh | sudo bash -s -- "user1" "user2" "user3"

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "🗑️ Remove Linux users"
rootCheck


## Read usernames-as-arguments from the command-line
USERS_TO_REMOVE=("$@")
for NAME in "${USERS_TO_REMOVE[@]}"; do

  fxTitle "🔪 Deleting user ${NAME}..."

  if ! id "$NAME" &>/dev/null; then
    fxInfo "It doesn't exist, skipping 🦘"
    continue
  fi

  sudo killall -u "$NAME"
  sudo deluser --remove-home "$NAME"
  if [ $? -ne 0 ]; then
    fxWarning "error deleting Linux user $NAME"
  fi

done


fxEndFooter
