#!/usr/bin/env bash
### SYSTEM TOOLS GUI by WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/system/zzsystem.sh

TITLE="System management GUI"
OPTIONS=(
  1 "⏲️  Benchmark (CPU + disk)"
  2 "🧬  Regenerate identity: SSH host keys + machine-id (reboot)"
)

source "/usr/local/turbolab.it/webstackup/script/base-gui.sh"

case $CHOICE in
  1) bash ${WEBSTACKUP_SCRIPT_DIR}system/benchmark.sh;;
  2) bash ${WEBSTACKUP_SCRIPT_DIR}system/regenerate-identity.sh;;
esac
