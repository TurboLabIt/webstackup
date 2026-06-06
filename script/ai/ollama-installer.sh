#!/usr/bin/env bash
### AUTOMATIC OLLAMA INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/ai/ollama-installer.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/ai/ollama-installer.sh | sudo bash
#
# Based on: https://ollama.com/download/linux

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🦙 ollama installer"
rootCheck


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}setup-if-stale.sh" ]; then
  "${WSU_DIR}setup-if-stale.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "Running the official ollama installer..."
curl -fsSL https://ollama.com/install.sh | sh


WSU_OLLAMA_SERVICE_OVERRIDE_PATH=/etc/systemd/system/ollama.service.d/
fxTitle "Linking the custom service file from ##${WSU_OLLAMA_SERVICE_OVERRIDE_PATH}##..."
fxWarning "The API is exposed on every interface, with no auth! On servers with a public IP, firewall port 11434"
mkdir -p ${WSU_OLLAMA_SERVICE_OVERRIDE_PATH}
fxLink "${WEBSTACKUP_CONFIG_DIR}ai/ollama.service" "${WSU_OLLAMA_SERVICE_OVERRIDE_PATH}30-webstackup.conf"
systemctl daemon-reload
systemctl show --no-pager -p FragmentPath -p DropInPaths ollama


fxTitle "Restarting the service..."
systemctl restart ollama


fxTitle "Final check..."
ollama --version
ss -tlnp | grep 11434
curl http://127.0.0.1:11434/


fxTitle "Installing Gemma 4 12B QAT..."
fxInfo "12B parameters, instruction-tuned, quantization-aware-trained"
fxInfo "Req.: 12 GB of RAM (CPU+GPU)"
ollama pull gemma4:12b-it-qat


fxTitle "Testing the API..."
fxInfo "Explain what webstackup is in max 50 words"
apt update && apt install jq -y
curl -s http://127.0.0.1:11434/api/generate -d '{
  "model": "gemma4:12b-it-qat",
  "prompt": "Explain what webstackup is in max 50 words",
  "stream": false
}' | jq


fxTitle "Benchmarking..."
ollama run gemma4:12b-it-qat --verbose "Write one sentence about webstackup"


fxEndFooter
