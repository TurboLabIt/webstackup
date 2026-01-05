#!/usr/bin/env bash
### AUTOMATIC LINKWARDEN UPDATER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/linkwarden/update.sh
#
# Run this via /etc/turbolab.it/zzupdate.conf : 
# ADDITIONAL_UPDATE_SCRIPT=/usr/local/turbolab.it/webstackup/script/linkwarden/update.sh
#

LOCAL_INSTALL_SCRIPT=/usr/local/turbolab.it/webstackup/script/linkwarden/install.sh
if [ -f "${LOCAL_INSTALL_SCRIPT}" ]; then

  bash "${LOCAL_INSTALL_SCRIPT}"

else

  curl -Ls https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/linkwarden/install.sh
fi
