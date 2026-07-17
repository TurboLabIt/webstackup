#!/usr/bin/env bash
### AUTOMATIC REDIS INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/redis/install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/redis/install.sh | sudo bash
#
# Based on: https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Redis installer"
rootCheck


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}setup-if-stale.sh" ]; then
  "${WSU_DIR}setup-if-stale.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "Removing any old previous instance..."
apt purge --auto-remove redis* -y
rm -rf /etc/redis


fxTitle "Installing prerequisites..."
apt update -qq
apt install curl gnupg2 ca-certificates lsb-release -y


fxTitle "Import the official redis signing key..."
rm -rf /usr/share/keyrings/*redis*
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/redis-archive-keyring.gpg >/dev/null
chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg


fxTitle "Verify that the downloaded file contains the proper key..."
gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/redis-archive-keyring.gpg


fxTitle "Adding the repo to APT..."
rm -rf /etc/apt/sources.list.d/*redis*
cat <<EOF | sudo tee /etc/apt/sources.list.d/webstackup-redis.sources
Types: deb
URIs: https://packages.redis.io/deb
Suites: $(lsb_release -cs)
Components: main
Signed-By: /usr/share/keyrings/redis-archive-keyring.gpg
EOF

ls -la /etc/apt/sources.list.d/


fxTitle "Set up repository pinning to prefer our packages over distribution-provided ones..."
echo -e "Package: *\nPin: origin packages.redis.io\nPin: release o=packages.redis.io\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99redis


fxTitle "apt install redis..."
apt update -qq
apt install redis -y


fxTitle "Enabling the drop-in config directory..."
mkdir -p /etc/redis/redis.conf.d
cat <<EOF >> /etc/redis/redis.conf


### WEBSTACKUP DROP-IN CONFIG DIRECTORY
## must stay at the end of this file: every directive found here overrides any previous value (last-one-wins)
include /etc/redis/redis.conf.d/*.conf
EOF

fxTitle "Limiting the RAM usage..."
fxLink "${WEBSTACKUP_CONFIG_DIR}redis/max-memory.conf" /etc/redis/redis.conf.d/30-webstackup-max-memory.conf

fxTitle "Disabling persistence..."
fxLink "${WEBSTACKUP_CONFIG_DIR}redis/disable-persistence.conf" /etc/redis/redis.conf.d/30-webstackup-disable-persistence.conf


fxTitle "Service management..."
systemctl enable redis-server
service redis-server restart
systemctl --no-pager status redis-server


fxTitle "Testing..."
redis-cli ping
redis-cli config get maxmemory maxmemory-policy save appendonly


fxTitle "Netstat..."
ss -lpt | grep -i redis

fxEndFooter
