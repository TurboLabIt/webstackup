#!/usr/bin/env bash

PLAY_SOUND_CMD="/usr/bin/aplay"
if [ ! -x "${PLAY_SOUND_CMD}" ]; then
  echo -e "\e[1;43m Unable to play-sound.sh: ${PLAY_SOUND_CMD} not found or not-executable \e[0m"
  exit
fi


FILE_TO_PLAY=$1
if [ -z "${FILE_TO_PLAY}" ]; then
  echo -e "\e[1;41m Please provide a file to play \e[0m"
  exit
fi


if [ ! -f "${FILE_TO_PLAY}" ]; then
  echo -e "\e[1;41m File to play not found ${FILE_TO_PLAY} not found \e[0m"
  exit
fi

${PLAY_SOUND_CMD} "${FILE_TO_PLAY}" >/dev/null 2>&1

