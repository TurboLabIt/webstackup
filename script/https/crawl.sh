#!/usr/bin/env bash
## Crawl a website by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/crawl.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/crawl.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

fxHeader "🕷️ Site crawler"

if [ -z $(command -v httrack) ]; then

  fxTitle "HTTrack is not installed. Installing it now..."
  sudo apt update
  sudo apt install httrack -y
fi

if [ -z "$1" ]; then
  CRAWLER_URL=${SITE_URL}
else
  CRAWLER_URL=$1
fi

if [ -z "$1" ]; then
  fxCatastrophicError "URL not set! Set SITE_URL in your project script_begin.sh or provide SITE_URL"
fi

CRAWLER_BASE_URL=$(echo "$CRAWLER_URL" | cut -d/ -f1-3)

fxTitle "HTTracking..."
fxMessage "Entrypoint:    ##${CRAWLER_URL}##"
fxMessage "Base URL:      ##${CRAWLER_BASE_URL}##"

httrack "${CRAWLER_URL}" "-*" "+${CRAWLER_BASE_URL}/*" -r2
