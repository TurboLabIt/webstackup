#!/usr/bin/env bash
if [ -z "$(command -v figlet)" ] || [ -z "$(command -v lolcat)" ]; then
  sudo apt install figlet lolcat -y -qq
fi

figlet "$(hostname)" | /usr/games/lolcat
