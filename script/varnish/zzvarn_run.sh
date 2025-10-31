#!/usr/bin/env bash
### VARNISH TOOLS GUI by WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/varnish/zzvarn.sh

TITLE="Varnish server management GUI"
OPTIONS=(
  1 "🧹  Cache clear"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1) varnishadm 'ban req.url ~ .';;
esac
