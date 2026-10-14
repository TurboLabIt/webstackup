#!/usr/bin/env bash
### PURE-FTPD USER MANAGER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/pure-ftpd/user-manager.sh
#
# Create a new FTP user or edit an existing one. The virtual users are mapped on ftp-data:www-data
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/pure-ftpd/user-manager.sh | sudo bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "👥 Pure-FTPd user manager"
rootCheck

if [ -z "$(command -v pure-pw)" ]; then
  fxCatastrophicError "Pure-FTPd is not installed"
fi


## https://github.com/TurboLabIt/webstackup/blob/master/script/account/generate-ftp-data.sh
if [ -f "/usr/local/turbolab.it/webstackup/script/account/generate-ftp-data.sh" ]; then

  bash "/usr/local/turbolab.it/webstackup/script/account/generate-ftp-data.sh"

else

  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/generate-ftp-data.sh | sudo bash
fi


fxTitle "👥 Current FTP users"
pure-pw list


fxTitle "👤 Username"
while [ -z "$FTP_USERNAME" ]; do

  echo "🤖 Provide the username (an existing one to edit it, a new one to create it)"
  read -p ">> " FTP_USERNAME  < /dev/tty

  if [ ! -z "$FTP_USERNAME" ] && [[ ! "$FTP_USERNAME" =~ ^[A-Za-z0-9._-]+$ ]]; then

    fxWarning "Only letters, numbers, dots, dashes and underscores, please"
    FTP_USERNAME=
  fi

done

if pure-pw show "$FTP_USERNAME" &>/dev/null; then

  FTP_USER_MODE=edit
  FTP_HOME_CURRENT=$(pure-pw show "$FTP_USERNAME" | grep '^Directory' | sed -E 's/^Directory\s*:\s*//; s|/\./?$||')
  fxOK "##$FTP_USERNAME## exists: editing mode ✏️"

else

  FTP_USER_MODE=create
  fxOK "##$FTP_USERNAME## doesn't exist: creating it ✨"
fi


fxTitle "🔑 Password"
while true; do

  if [ "$FTP_USER_MODE" = edit ]; then
    echo "🤖 Provide the new password or just hit Enter to keep the current one"
  else
    echo "🤖 Provide the password"
  fi

  read -s -p ">> " FTP_PASSWORD  < /dev/tty
  echo

  if [ -z "$FTP_PASSWORD" ] && [ "$FTP_USER_MODE" = edit ]; then

    fxInfo "No changes to the password 🦘"
    break

  elif [ -z "$FTP_PASSWORD" ]; then

    fxWarning "The password is required for a new user"
    continue
  fi

  fxOK "Password OK"
  break
done


fxTitle "📁 Home directory"
fxInfo "For example: /var/www/my-app"
while [ -z "$FTP_HOME" ]; do

  if [ "$FTP_USER_MODE" = edit ]; then
    echo "🤖 Provide the full path (use TAB!) or just hit Enter to keep ##${FTP_HOME_CURRENT}##"
  else
    echo "🤖 Provide the full path (use TAB!)"
  fi

  read -ep ">> " FTP_HOME  < /dev/tty

  if [ -z "$FTP_HOME" ] && [ "$FTP_USER_MODE" = edit ]; then
    FTP_HOME=$FTP_HOME_CURRENT
  fi

done

# no trailing "/"
FTP_HOME=${FTP_HOME%/}

if [ ! -d "$FTP_HOME" ]; then

  fxInfo "##$FTP_HOME## doesn't exist, creating it..."
  mkdir -p "$FTP_HOME"
  chown ftp-data:www-data "$FTP_HOME"
fi

fxOK "OK, the home directory is ##${FTP_HOME}##"


if [ "$FTP_USER_MODE" = edit ]; then

  fxTitle "✏️ Editing ##$FTP_USERNAME##..."
  pure-pw usermod "$FTP_USERNAME" -u ftp-data -g www-data -d "$FTP_HOME"

  if [ ! -z "$FTP_PASSWORD" ]; then
    printf '%s\n%s\n' "$FTP_PASSWORD" "$FTP_PASSWORD" | pure-pw passwd "$FTP_USERNAME"
  fi

else

  fxTitle "✨ Creating ##$FTP_USERNAME##..."
  printf '%s\n%s\n' "$FTP_PASSWORD" "$FTP_PASSWORD" | pure-pw useradd "$FTP_USERNAME" -u ftp-data -g www-data -d "$FTP_HOME"
fi


fxTitle "💾 Updating the PureDB database..."
pure-pw mkdb


fxTitle "👤 ##$FTP_USERNAME##"
pure-pw show "$FTP_USERNAME"


fxEndFooter
