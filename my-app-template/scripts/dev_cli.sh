#!/usr/bin/env bash
## Main deploy script.
#
# ⚠️ Don't run this script directly! Use `bash deploy.sh` instead.
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/dev_cli.sh
clear
SCRIPT_NAME=dev_cli
source $(dirname $(readlink -f $0))/script_begin.sh
fxHeader "🧑‍💻 DEV cli"
fxTitle "Running on ${APP_ENV} ($HOSTNAME)"
devOnlyCheck
fxCatastrophicError "dev_cli.sh is not ready! Please customize it and remove this line when done"
#fxTitle "Changing permissions..."
#sudo chmod ugo=rwx "${PROJECT_DIR}" -R

if [ "$1" != "db:import" ] && [ "$1" != "db:download" ] && [ -f "${SCRIPT_DIR}migrate.sh" ]; then
  bash "${SCRIPT_DIR}migrate.sh"
fi

if [ "$1" = "cache" ]; then

  bash "${PROJECT_DIR}script/cache-clear.sh" $2
  
elif [ "$1" = "composer" ]; then

  wsuComposer "${@:2}"

elif [ "$1" = "db:import" ]; then

  ## for Magento only (remove if this is NOT a Magento-based app)
  wsuN98MageRun db:import ../backup/dbdump_dev.sql.gz --drop --compression=gzip
  
  ## for zzmysqldump
  DOWEEK="$(date +'%u')"
  FILENAME=my-app_${DOWEEK}.sql.7z
  zzmysqlimp ${PROJECT_DIR}backup/zzmysqldump/${FILENAME}
  
  ## post-import fixup
  if [ -f "${PROJECT_DIR}config/custom/dev/db-post-import.sql" ]; then
     wsuMysql < ${PROJECT_DIR}config/custom/dev/db-post-import.sql  
  fi
  
  ## migrating
  if [ -f "${SCRIPT_DIR}migrate" ]; then
    bash ${SCRIPT_DIR}migrate.sh
  fi

  bash "${PROJECT_DIR}script/cache-clear.sh"
  
elif [ "$1" = "db:download" ]; then

  echo "TO DO"
  
elif [ "$1" = "cmd" ]; then

  cd ${MAGENTO_DIR}
  XDEBUG_CONFIG="remote_host=127.0.0.1 client_port=9001" /bin/php${PHP_VER} bin/magento my:mage:cmd "${@:2}"

else

  fxCatastrophicError "Please provide a defined input procedure!"
fi

#fxTitle "Changing permissions..."
#sudo chmod ugo=rwx "${PROJECT_DIR}" -R

source ${SCRIPT_DIR}script_end.sh

