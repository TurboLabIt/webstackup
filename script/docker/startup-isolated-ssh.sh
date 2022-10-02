#!/usr/bin/env sh
## WEBSTACKUP DOCKER STARTUP SCRIPT FOR ISOLATED SSH ACCESS
#
# This is your own copy of https://github.com/TurboLabIt/webstackup/blob/master/script/docker/startup-isolated-ssh.sh
# Edit to your needs!

## server key generation
ssh-keygen -A

## disable password login via SSH
if grep -qi webstackup "/etc/ssh/sshd_config"; then
  
  echo "" >> /etc/ssh/sshd_config
  echo "## https://github.com/TurboLabIt/webstackup/blob/master/script/docker/startup-isolated-ssh.sh" >> /etc/ssh/sshd_config
  echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
fi

## start OpenSSH
/usr/sbin/sshd -D
