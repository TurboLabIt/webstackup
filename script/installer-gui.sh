#!/usr/bin/env bash
### SOFTWARE INSTALLER by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/installer-gui.sh

TITLE="Software installer"
OPTIONS=(
  1 "💿  node.js, yarn, webpack"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1)bash "${WEBSTACKUP_SCRIPT_DIR}node.js/install.sh";;
esac
