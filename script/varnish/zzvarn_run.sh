#!/usr/bin/env bash
### VARNISH TOOLS GUI by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/varnish/zzvarn.sh

TITLE="Varnish server management GUI"
OPTIONS=(
  1 "🧹  Cache clear"
  2 "👁️‍🗨️  Cache monitor"
  3 "📄  URL monitor"
  4 "🛠️  Show service config path(s)"
  5 "🚨  5xx / FetchError monitor"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1) varnishadm 'ban req.url ~ .';;
  2) bash ${WEBSTACKUP_SCRIPT_DIR}varnish/monitor-cache.sh;;
  3) varnishncsa -F '%U%q %{Varnish:hitmiss}x';;
  4) sudo systemctl show -p FragmentPath -p DropInPaths varnish;;
  5) LOG="/var/log/varnish/5xx.log"; echo "📝 Logging to: $LOG"; sudo varnishlog -g request -q 'RespStatus >= 500 or BerespStatus >= 500 or FetchError' | sudo tee "$LOG";;
esac
