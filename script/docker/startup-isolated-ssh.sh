#!/usr/bin/env sh
## WEBSTACKUP DOCKER STARTUP SCRIPT FOR ISOLATED SSH ACCESS
#
# This is your own copy of https://github.com/TurboLabIt/webstackup/blob/master/script/docker/startup-isolated-ssh.sh
# Edit to your needs!

ssh-keygen -A
service ssh start
tail -f /dev/null
