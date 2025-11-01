#!/usr/bin/env bash
### SOFTWARE INSTALLER by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/installer-gui.sh

TITLE="Software installer"
OPTIONS=(
  1 "💿  node.js, yarn, webpack"
  2 "💿  MySQL"
  3 "💿  Pure-FTPd"
  4 "💿  Meilisearch"
  5 "💿  Let's Encrypt"
  6 "💿  Varnish"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1)bash "${WEBSTACKUP_SCRIPT_DIR}node.js/install.sh";;
  2)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/install.sh";;
  3)bash "${WEBSTACKUP_SCRIPT_DIR}pure-ftpd/install.sh";;
  4)bash "${WEBSTACKUP_SCRIPT_DIR}meilisearch/install.sh";;
  5)bash "${WEBSTACKUP_SCRIPT_DIR}https/letsencrypt-install.sh";;
  6)bash "${WEBSTACKUP_SCRIPT_DIR}varnish/install.sh";;
esac
