#!/usr/bin/env bash

LOCKFILE=${PROJECT_DIR}var/log/${SCRIPT_NAME}
lockCheck ${LOCKFILE}

source /etc/turbolab.it/mysql-${APP_NAME}.conf

fxTitle "Flush versions/asset..."
mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "DELETE from \`${MYSQL_DB_NAME}\`.versions where ctype='asset'" && \
  rm -rf ${PROJECT_DIR}var/versions/asset/*

fxTitle "Flush versions/document..."
mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "DELETE from \`${MYSQL_DB_NAME}\`.versions where ctype='document'" && \
  rm -rf ${PROJECT_DIR}var/versions/document/*

fxTitle "Flush versions/object..."
mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "DELETE from \`${MYSQL_DB_NAME}\`.versions where ctype='object'" && \
  rm -rf ${PROJECT_DIR}var/versions/object/*

fxTitle "Flush recyclebin..."
mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "TRUNCATE TABLE \`${MYSQL_DB_NAME}\`.recyclebin" && \
  rm -rf ${PROJECT_DIR}var/recyclebin/*

fxTitle "Flush public/var/tmp (not modified in the last 7 days)..."
if [ -d "${WEBROOT_DIR}var/tmp" ]; then
  find "${WEBROOT_DIR}var/tmp/" -mindepth 1 -mtime +7 -type f -delete
  find "${WEBROOT_DIR}var/tmp/" -mindepth 1 -type d -empty -delete
else
  fxInfo "##${WEBROOT_DIR}var/tmp## not found, nothing to do"
fi
