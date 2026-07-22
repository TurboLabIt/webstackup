#!/usr/bin/env bash

TITLE="Server management GUI"
OPTIONS=(
  1 "🔄   Web services re-start (zzws)"
  2 "♻️   Web services re-load"
  3 "✔️   Self-update"
  4 "🐑   Git clone an existing app"
  5 "🛢️   MySQL GUI (zzdb) ☰"
  6 "🔏   HTTPS certificates ☰"
  7 "👮   Webpermissions a directory"
  8 "🔑   Show webstackup SSH pub key"
  9 "💌   Email GUI (zzmail) ☰"
  10 "🔍   Meilisearch GUI ☰"
  11 "💿   Installer GUI ☰"
  12 "🪣   Varnish GUI ☰"
  13 "🔬   URL checker"
  14 "🗺️   IP checker"
  15 "📛   Rename this system (hostname)"
  88 "🐫   my-app-template"
  #99 "🧪   WSU Dev (MAP test)"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"


function wsuzzws()
{
  if [ -f "${WEBSTACKUP_INSTALL_DIR_PARENT}zzalias/zzws.sh" ]; then
    sudo bash ${WEBSTACKUP_INSTALL_DIR_PARENT}zzalias/zzws.sh $1
  else
    curl -s https://raw.githubusercontent.com/TurboLabIt/zzalias/master/zzws.sh | sudo bash
  fi
}


case $CHOICE in
  1)wsuzzws;;
  2)wsuzzws reload;;
  3)
    git -C "${WEBSTACKUP_INSTALL_DIR}" reset --hard
    git -C "${WEBSTACKUP_INSTALL_DIR}" pull
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    wsuzzws
    ;;
  4)
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    bash "${WEBSTACKUP_SCRIPT_DIR}mysql/new.sh"
    bash "${WEBSTACKUP_SCRIPT_DIR}filesystem/git-clone.sh"
    ;;
  5)bash "${WEBSTACKUP_SCRIPT_DIR}mysql/zzdb.sh";;
  6)bash "${WEBSTACKUP_SCRIPT_DIR}https/zzhttps.sh";;
  7)bash "${WEBSTACKUP_SCRIPT_DIR}filesystem/webpermission.sh";;
  8)fxMessage "$(cat "/home/webstackup/.ssh/id_rsa.pub")";;
  9)bash "${WEBSTACKUP_SCRIPT_DIR}mail/zzmail.sh";;
  10)bash "${WEBSTACKUP_SCRIPT_DIR}meilisearch/zzmeili.sh";;
  11)bash "${WEBSTACKUP_SCRIPT_DIR}installer-gui.sh";;
  12)bash "${WEBSTACKUP_SCRIPT_DIR}varnish/zzvarn.sh";;
  13)bash "${WEBSTACKUP_SCRIPT_DIR}https/url-checker.sh";;
  14)bash "${WEBSTACKUP_SCRIPT_DIR}network/ip-checker.sh";;
  15)fxHostnameRename;;
  88)
    bash "${WEBSTACKUP_INSTALL_DIR}setup.sh"
    bash "${WEBSTACKUP_INSTALL_DIR}my-app-template/setup.sh"
    ;;
  99)bash "${WEBSTACKUP_INSTALL_DIR}my-app-template/setup_test.sh";;
esac
