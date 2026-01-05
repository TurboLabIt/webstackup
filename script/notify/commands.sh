#!/usr/bin/env bash
### READY-TO-RUN, NOTIFICATION COMMANDS BY WEBSTACKUP

WEBSTACKUP_SOUND_DIR=${WEBSTACKUP_INSTALL_DIR}asset/sound/
WEBSTACKUP_PLAYSOUND_CMD=${WEBSTACKUP_SCRIPT_DIR}notify/play-sound.sh

function wsuPlaySound()
{
  bash "${WEBSTACKUP_PLAYSOUND_CMD}" "$1"
}


function wsuPlayOKSound()
{
  wsuPlaySound "${WEBSTACKUP_SOUND_DIR}mario-coin.wav"
}


function wsuPlayKOSound()
{
  wsuPlaySound "${WEBSTACKUP_SOUND_DIR}cannon.wav"
}
