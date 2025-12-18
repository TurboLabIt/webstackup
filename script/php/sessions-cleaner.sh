#!/usr/bin/env bash
### PHP SESSIONS CLEANER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/php/sessions-cleaner.sh

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧹 PHP sessions cleaner"
rootCheck

if [ -z "${PHP_SESSION_CLEANER_MAX_DAYS}" ]; then
  ## default to "about 7 months"
  PHP_SESSION_CLEANER_MAX_DAYS=217
fi

PHP_SESSIONS_DIR=/var/lib/php/sessions

fxInfo "Deleting files older than ##${PHP_SESSION_CLEANER_MAX_DAYS}## days from ##${PHP_SESSIONS_DIR}##"

if [ -d ${PHP_SESSIONS_DIR} ]; then

  fxInfo "There are ##$( ls -1 ${PHP_SESSIONS_DIR} | wc -l)## files before the cleanse"
  sudo find ${PHP_SESSIONS_DIR} -type f -mtime +${PHP_SESSION_CLEANER_MAX_DAYS} -exec rm {} \;
  fxOK "Cleanse completed ##$( ls -1 ${PHP_SESSIONS_DIR} | wc -l)## files remain"

else

  fxWarning "Directory ##${PHP_SESSIONS_DIR}## not found"
fi


fxEndFooter
