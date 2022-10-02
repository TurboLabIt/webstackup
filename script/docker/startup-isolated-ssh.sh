#!/usr/bin/env bash
## WEBSTACKUP DOCKER STARTUP SCRIPT FOR ISOLATED SSH
#
# This is your own copy of https://github.com/TurboLabIt/webstackup/blob/master/script/docker/startup-isolated-ssh.sh
# Edit to your needs!

service ssh start

if [ -f /usr/local/turbolab.it/zzalias/zzalias.sh ]; then
  source /usr/local/turbolab.it/zzalias/zzalias.sh
fi
