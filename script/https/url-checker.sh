#!/usr/bin/env bash
### URL CHECKER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/https/url-checker.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/url-checker.sh | sudo bash

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 URL checker"

fxTitle "📃 URLs to check"
while [ -z "$WSU_URL_LIST" ]; do

  echo "🤖 Provide the list of URL to check, one per line. Hit Ctrl+D when done"
  WSU_URL_LIST=$(cat)
done


fxTitle "🔢 Expected HTTP status"
while [ -z "$WSU_URL_EXPECTED_HTTP_STATUS" ]; do

  echo "🤖 Provide the expected HTTP status. Hit Enter for '200'"
  read -p ">> " WSU_URL_EXPECTED_HTTP_STATUS  < /dev/tty
  if [ -z "$WSU_URL_EXPECTED_HTTP_STATUS" ]; then
    WSU_URL_EXPECTED_HTTP_STATUS=200
  fi

done

# Define an array with the sleep durations in seconds
SLEEP_CHOICES=(0.25 0.5 1)

fxTitle "🔍 Checking..."
URL_CHECKED=0
URL_INVALID=0
URL_OK=0
URL_KO=0

while IFS= read -r line; do

  # Remove leading and trailing whitespace (trim)
  URL=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Check if the trimmed line is empty; if so, skip it silently
  if [ -z "$URL" ]; then
    continue
  fi

  # Check for invalid URL
  if [[ "$URL" != http://* ]] && [[ "$URL" != https://* ]]; then

    echo -ne "\r"
    fxWarning "$URL"
    fxWarning "Invalid URL"
    URL_INVALID=$(( URL_INVALID + 1 ))
    echo ""
    continue
  fi

  URL_CHECKED=$(( URL_CHECKED + 1 ))

  HTTP_RESPONSE=$(curl -o /dev/null -s -w "%{http_code}" "$URL")

  # Check if the response status code is different from the expected
  if [ "$HTTP_RESPONSE" -ne "$WSU_URL_EXPECTED_HTTP_STATUS" ]; then

    echo -ne "\r"
    fxWarning "$URL"
    fxWarning "The HTTP status code is $HTTP_RESPONSE"
    URL_KO=$(( URL_KO + 1 ))
    echo ""
    continue
  fi

  URL_OK=$(( URL_OK + 1 ))

  # Generate a random index between 0 and 2
  RANDOM_SLEEP_INDEX=$(( RANDOM % 3 ))
  SLEEP_DURATION=${SLEEP_CHOICES[$RANDOM_SLEEP_INDEX]}
  sleep "$SLEEP_DURATION"

  echo -ne "\r$URL_CHECKED URLs checked"

done <<< "$WSU_URL_LIST"


fxTitle "🐦‍🔥 Report"
echo "Invalid URLs : $URL_INVALID"
echo "Checked URLs : $URL_CHECKED"
echo ""
echo "OK URLs      : $URL_OK"
echo "KO URLs      : $URL_KO"

fxEndFooter
