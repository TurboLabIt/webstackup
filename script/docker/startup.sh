#!/usr/bin/env bash
## WEBSTACKUP DOCKER STARTUP SCRIPT
#
# This is your own copy of https://github.com/TurboLabIt/webstackup/blob/master/script/docker/startup.sh
# Edit to your needs!

source /usr/local/turbolab.it/webstackup/script/base.sh

service ssh start
service nginx start
service ${PHP_FPM} start

if [ -f /usr/local/turbolab.it/zzalias.sh ]; then
  source /usr/local/turbolab.it/zzalias.sh
fi
