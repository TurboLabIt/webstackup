#!/usr/bin/env bash
### AUTOMATIC OPENSEARCH INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/opensearch/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/opensearch/install.sh | sudo bash
#
# Based on: https://docs.opensearch.org/latest/install-and-configure/install-opensearch/debian/#install-opensearch-from-an-apt-repository

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 OpenSearch installer"
rootCheck

fxTitle "Selecting the version..."
if [ -z "${OPENSEARCH_VER}" ]; then
  OPENSEARCH_VER=3
fi

fxOK "OpenSearch v.${OPENSEARCH_VER}.x selected"

fxTitle "Removing any old previous instance..."
apt purge --auto-remove opensearch* -y
rm -rf /etc/opensearch

## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ ! -f "${WSU_DIR}setup.sh" ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "Installing prerequisites..."
apt update -qq
apt install apt-transport-https software-properties-common lsb-release ca-certificates curl gnupg2 jq -y


fxTitle "Importing the signing key..."
curl -fsSL https://artifacts.opensearch.org/publickeys/opensearch-release.pgp \
 | sudo gpg --dearmor -o /etc/apt/keyrings/opensearch.gpg


fxTitle "Adding the repo to APT..."
echo "deb [signed-by=/etc/apt/keyrings/opensearch.gpg] https://artifacts.opensearch.org/releases/bundle/opensearch/3.x/apt stable main" \
| sudo tee /etc/apt/sources.list.d/opensearch-3.x.list


fxTitle "Set up repository pinning to prefer our packages over distribution-provided ones..."
echo -e "Package: *\nPin: origin artifacts.opensearch.org\nPin: release o=opensearch\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99opensearch


fxTitle "Dealing with the admin password..."
if [ ! -f "/etc/turbolab.it/opensearch.conf" ]; then

  OPENSEARCH_ADMIN_PASSWORD="$(fxPasswordGenerator)"
  echo "OPENSEARCH_ADMIN_PASSWORD=${OPENSEARCH_ADMIN_PASSWORD}" > "/etc/turbolab.it/opensearch.conf"

  OPENSEARCH_USER_PASSWORD="$(fxPasswordGenerator)"
  echo "OPENSEARCH_USER_PASSWORD=${OPENSEARCH_USER_PASSWORD}" >> "/etc/turbolab.it/opensearch.conf"
fi

source "/etc/turbolab.it/opensearch.conf"
fxMessage "Password stored in /etc/turbolab.it/opensearch.conf"


fxTitle "apt install opensearch..."
apt update -qq
env OPENSEARCH_INITIAL_ADMIN_PASSWORD=${OPENSEARCH_ADMIN_PASSWORD} apt-get install opensearch -y


fxTitle "Deploy a base config..."
echo "" >> /etc/opensearch/opensearch.yml
cat "${WEBSTACKUP_CONFIG_DIR}opensearch/opensearch.yml" >> /etc/opensearch/opensearch.yml
fxLink "${WEBSTACKUP_CONFIG_DIR}elasticsearch/jvm.options" /etc/opensearch/jvm.options.d/


fxTitle "Creating the ##wsu_app## account for the application to use..."
curl -s -X PUT "https://localhost:9210/_plugins/_security/api/internalusers/wsu_app" -u "admin:${OPENSEARCH_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d "{
    \"password\": \"${OPENSEARCH_USER_PASSWORD}\",
    \"description\": \"App user (webstackup)\"
  }" --insecure | jq

curl -s -X PUT "https://localhost:9210/_plugins/_security/api/roles/wsu_app_access" \
  -u "admin:${OPENSEARCH_ADMIN_PASSWORD}" -H "Content-Type: application/json" \
  -d '{
    "cluster_permissions": [
      "cluster_composite_ops",
      "cluster:monitor/main",
      "cluster:monitor/health",
      "cluster:monitor/state",
      "cluster:monitor/nodes/info",
      "indices:data/read/scroll*"
    ],
    "index_permissions": [{
      "index_patterns": ["*"],
      "allowed_actions": [
        "indices:admin/create",
        "indices:admin/delete",
        "indices:admin/mapping/put",
        "indices:admin/mappings/get",
        "indices:admin/refresh",
        "indices:admin/settings/update",
        "indices:admin/get",
        "indices:admin/exists",
        "indices:data/write/index",
        "indices:data/write/bulk",
        "indices:data/write/delete",
        "indices:data/write/update",
        "indices:data/read/search",
        "indices:data/read/get",
        "indices:monitor/stats"
      ]
    }]
  }' --insecure | jq

curl -s -X PUT "https://localhost:9210/_plugins/_security/api/rolesmapping/wsu_app_access" \
  -u "admin:${OPENSEARCH_ADMIN_PASSWORD}" -H "Content-Type: application/json" \
  -d '{"users": ["wsu_app"]}' --insecure | jq


fxTitle "Service management..."
systemctl enable opensearch
service opensearch restart
systemctl --no-pager status opensearch
sleep 7


fxTitle "Testing (admin)..."
curl -s -X GET https://localhost:9210 -u "admin:${OPENSEARCH_ADMIN_PASSWORD}" --insecure | jq -Rr 'fromjson? // .'

fxTitle "Testing (wsu_app)..."
curl -s -X GET https://localhost:9210 -u "wsu_app:${OPENSEARCH_USER_PASSWORD}" --insecure | jq -Rr 'fromjson? // .'


fxTitle "Netstat..."
ss -lpt | grep -i 'java\|open'


fxTitle "Your credentials (for application use)"
fxMessage "Host:          ##localhost##"
fxMessage "Port:          ##9210##"
fxMessage "User:          ##wsu_app##"
fxMessage "Password:      ##$OPENSEARCH_USER_PASSWORD##"


fxEndFooter
