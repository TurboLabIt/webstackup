#!/usr/bin/env bash

if [ -z "$(command -v figlet)" ] || [ ! -f "/usr/games/lolcat" ]; then
  sudo apt install figlet lolcat -y -qq
fi

figlet "$(hostname)" | /usr/games/lolcat -f
echo "🚀🚀 Provisioned with Webstackup 🚀🚀" | /usr/games/lolcat -f
