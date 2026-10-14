#!/usr/bin/env bash
### FTP TOOLS GUI by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/pure-ftpd/zzftp.sh

TITLE="FTP server management GUI"
OPTIONS=(
  1 "👥  List FTP users"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1) fxTitle "👥 FTP users" && pure-pw list;;
esac
