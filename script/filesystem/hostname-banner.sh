#!/usr/bin/env bash

if [ -z "$(command -v figlet)" ]; then
  apt install figlet -y -qq
fi

figlet "$(hostname)"
