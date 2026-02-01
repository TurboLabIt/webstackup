#!/usr/bin/env bash
### SOFTWARE INSTALLER by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/installer-gui.sh

TITLE="Software installer"
OPTIONS=(
  1 "💿  PHP"
  2 "💿  MySQL"
  3 "💿  node.js, yarn, webpack"
  4 "💿  Pure-FTPd"
  5 "💿  Meilisearch"
  6 "💿  Let's Encrypt"
  7 "💿  Varnish"
  8 "💿  OpenSearch"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1)bash "${WEBSTACKUP_SCRIPT_DIR}php/install.sh";;
  2)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/install.sh";;
  3)bash "${WEBSTACKUP_SCRIPT_DIR}node.js/install.sh";;
  4)bash "${WEBSTACKUP_SCRIPT_DIR}pure-ftpd/install.sh";;
  5)bash "${WEBSTACKUP_SCRIPT_DIR}meilisearch/install.sh";;
  6)bash "${WEBSTACKUP_SCRIPT_DIR}https/letsencrypt-install.sh";;
  7)bash "${WEBSTACKUP_SCRIPT_DIR}varnish/install.sh";;
  8)bash "${WEBSTACKUP_SCRIPT_DIR}opensearch/install.sh";;
esac
