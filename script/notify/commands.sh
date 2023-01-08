#!/usr/bin/env bash
### READY-TO-RUN, NOTIFICATION COMMANDS BY WEBSTACK.UP

WEBSTACKUP_SOUND_DIR=${WEBSTACKUP_INSTALL_DIR}asset/sound/
WEBSTACKUP_PLAYSOUND_CMD=${WEBSTACKUP_SCRIPT_DIR}notify/play-sound.sh

function wsuPlaySound()
{
  bash "${WEBSTACKUP_PLAYSOUND_CMD}" "$1"
}


function wsuPlayOKSound()
{
  wsuPlaySound "${WEBSTACKUP_SOUND_DIR}mario-stage-clear.wav"
}


function wsuPlayKOSound()
{
  wsuPlaySound "${WEBSTACKUP_SOUND_DIR}cannon.wav"
}
