#!/usr/bin/env bash
### AUTOMATIC ELASTICSEARCH INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/elasticsearch/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/elasticsearch/install.sh | sudo bash
#
# Based on: 

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 ElasticSearch installer"
rootCheck

fxTitle "Selecting the version..."
if [ -z "${ELASTICSEARCH_VER}" ]; then

  ## ES 8 introduces some major changes (HTTPS, auth, ...)
  # here we use a more conservative, older version by default
  ELASTICSEARCH_VER=7
fi

fxInfo "ElasticSearch ${ELASTICSEARCH_VER} selected"

fxTitle "Removing any old previous instance..."
apt purge --auto-remove elasticsearch* -y
rm -rf /etc/elasticsearch

## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ ! -f "${WSU_DIR}setup.sh" ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"

fxTitle "Importing the signing key..."
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch.gpg

fxTitle "Adding the repo to APT..."
echo "deb [signed-by=/usr/share/keyrings/elasticsearch.gpg] https://artifacts.elastic.co/packages/${ELASTICSEARCH_VER}.x/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/elasticsearch.list

fxTitle "Set up repository pinning to prefer our packages over distribution-provided ones..."
echo -e "Package: *\nPin: origin artifacts.elastic.co\nPin: release o=elasticsearch\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99elasticsearch

fxTitle "apt install elasticsearch..."
apt update -qq
apt install elasticsearch -y

fxTitle "Linking a base config..."
fxLink "${WEBSTACKUP_CONFIG_DIR}elasticsearch/jvm.options" /etc/elasticsearch/jvm.options.d/

fxTitle "Service management..."
systemctl enable elasticsearch
service elasticsearch restart
systemctl --no-pager status elasticsearch

fxTitle "Testing..."
curl -X GET 'http://localhost:9200'

fxTitle "Disabling replicas..."
curl -X PUT http://localhost:9200/_template/default -H 'Content-Type: application/json' -d \
  '{"index_patterns": ["*"],"order": -1,"settings": {"number_of_shards": "1","number_of_replicas": "0"}}'

fxTitle "Netstat..."
ss -lpt | grep -i 'java\|elastic'

fxEndFooter
