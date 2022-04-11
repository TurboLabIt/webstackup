#!/usr/bin/env bash

if [ -z "$(command -v figlet)" ]; then
  sudo apt install figlet -y -qq
fi

figlet "$(hostname)"
