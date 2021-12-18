#!/usr/bin/env bash
source /usr/local/turbolab.it/webstackup/script/base.sh
service ssh start
service nginx start
service ${PHP_FPM} start

if [ -f /usr/local/turbolab.it/zzalias.sh ]; then
  source /usr/local/turbolab.it/zzalias.sh
fi

echo "Here we go..."
/usr/bin/bash
