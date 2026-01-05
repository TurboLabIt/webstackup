#!/usr/bin/env bash
### HTTPS certificates tools GUI by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/https/zzhttps.sh

TITLE="HTTPS certificates tools GUI"
OPTIONS=(
  1 "🔏   Let's Encrypt a domain"
  2 "🩹   Generate a self-signed certificate (wildcard)"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1)bash "${WEBSTACKUP_SCRIPT_DIR}https/letsencrypt-generate.sh";;
  2)bash "${WEBSTACKUP_SCRIPT_DIR}https/self-sign-generate.sh";;
esac
