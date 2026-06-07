#!/usr/bin/env bash
### AUTOMATIC GEMMA-ON-OLLAMA INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/ai/gemma-installer.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/ai/gemma-installer.sh | sudo bash
#
# Based on: https://ollama.com/library/gemma4 | https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💎 Gemma installer"
rootCheck


## installing/updating ollama (this installs/updates WSU too)
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}script/ai/ollama-installer.sh" ]; then
  bash "${WSU_DIR}script/ai/ollama-installer.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/ai/ollama-installer.sh | sudo bash
fi


fxTitle "Installing prerequisites..."
apt update -qq
apt install jq -y


fxTitle "Installing Gemma 4 12B QAT..."
fxInfo "12B parameters, instruction-tuned, quantization-aware-trained"
fxInfo "Req.: 16 GB of RAM (CPU+GPU)"
ollama pull gemma4:12b-it-qat


fxTitle "Testing the API..."
fxInfo "Q: Who are you?"
curl -s http://127.0.0.1:11434/api/generate -d '{
  "model": "gemma4:12b-it-qat",
  "prompt": "Who are you?",
  "stream": false
}' | jq -r '.response'


fxTitle "Benchmarking..."
fxInfo "Q: What is a Terminator? Answer in max 50 words"
ollama run gemma4:12b-it-qat --verbose "What is a Terminator? Answer in max 50 words"


fxEndFooter
