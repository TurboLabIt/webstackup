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

fxTitle "Checking HTTrack..."
if [ -z $(command -v httrack) ]; then

  fxInfo "HTTrack is not installed. Installing it now..."
  sudo apt update
  sudo apt install httrack -y

else

  fxOK "HTTrack is installed"
fi

if [ -z "$1" ]; then
  CRAWLER_URL=${SITE_URL}
else
  CRAWLER_URL=$1
fi

if [ -z "$CRAWLER_URL" ]; then
  fxCatastrophicError "URL not set! Set SITE_URL in your project script_begin.sh or provide SITE_URL"
fi

CRAWLER_BASE_URL=$(echo "$CRAWLER_URL" | cut -d/ -f1-3)


fxTitle "Creating the local mirror directory..."
CRAWLER_LOCAL_DIR=${PROJECT_DIR}backup/crawl-httrack
sudo -u "${EXPECTED_USER}" -H rm -rf "${CRAWLER_LOCAL_DIR}"
sudo -u "${EXPECTED_USER}" -H mkdir -p "${CRAWLER_LOCAL_DIR}"
fxOK "${CRAWLER_LOCAL_DIR}"


fxTitle "HTTracking..."
fxMessage "Entrypoint:    ##${CRAWLER_URL}##"
fxMessage "Base URL:      ##${CRAWLER_BASE_URL}##"
echo ""
sudo -u "${EXPECTED_USER}" -H httrack "${CRAWLER_URL}" "-*" "+${CRAWLER_BASE_URL}/*" -r2 -O "${CRAWLER_LOCAL_DIR}" \
  -v -s0 \
  -F "Mozilla/5.0 (X11; LinuxWSU x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"


fxTitle "Managing the mirror..."
if [ "${CRAWLER_PRESERVER_MIRROR}" != 1 ]; then

  fxInfo "Deleting ##${CRAWLER_LOCAL_DIR}##..."
  sudo -u "${EXPECTED_USER}" -H rm -rf "${CRAWLER_LOCAL_DIR}"

else

  fxInfo "Mirror kept! It's available in ##${CRAWLER_LOCAL_DIR}##"
fi
