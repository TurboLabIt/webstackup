#!/usr/bin/env bash
source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "🚀️ async script runner"
rootCheck

printTitle "Input received"
printMessage "📄 Filename to check: ##$1##"
printMessage "📜 Script to run: ##$2##"

if [ -z $1 ]; then
  catastrophicError "🛑 Filename to check not provided!"
  exit
fi

if [ -z $2 ] || [ ! -f "$2" ]; then
  catastrophicError "🛑 Script to run not found!"
  exit
fi

REQUEST_FILE=/tmp/${2}
printTitle "Looking for request file ##$REQUEST_FILE##..."
if [ ! -f "${REQUEST_FILE}" ]; then
  printMessage "💤 Request file not found. Sleeping..."
  printTheEnd
  exit
fi

rm -f "${REQUEST_FILE}"
printMessage "✅ Request file found! Running the script..."
bash "$2" ${@:3}
