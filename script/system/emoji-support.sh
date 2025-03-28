#!/usr/bin/env bash
### ADD EMOJI SUPPORT by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/system/emoji-support.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/system/emoji-support.sh | sudo bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💩 EMOJI FIXER"
rootCheck


fxTitle "Install locales package..."
apt update -qq
apt install locales -y


fxTitle "Reading current locale..."
# Generate only required locales based on the current config
CURRENT_LOCALE=$(grep '^LANG=' /etc/default/locale | cut -d= -f2 | tr -d '"')
TARGET_LOCALE="${CURRENT_LOCALE%.UTF-8}.UTF-8"

# Handle special case for C locale
if [[ "$CURRENT_LOCALE" == "C" ]]; then
    TARGET_LOCALE="C.UTF-8"
fi

fxInfo "Current locale: $CURRENT_LOCALE"
fxInfo "Updated locale: $TARGET_LOCALE"


fxTitle "Generating locale..."
locale-gen "$TARGET_LOCALE"

fxTitle "Setting locale..."
update-locale LANG="$TARGET_LOCALE"


fxTitle "Updated result..."
locale
echo ""

fxMessage "Do you see this green checkmark ##✅##?" 
fxMessage "If not, you must logout+login" 


fxEndFooter
