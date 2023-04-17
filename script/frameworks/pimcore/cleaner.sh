#!/usr/bin/env bash

SCRIPT_NAME=cleaner
source $(dirname $(readlink -f $0))/script_begin.sh

fxHeader "Flush Pimcore data storage"

LOCKFILE=${PROJECT_DIR}var/log/${SCRIPT_NAME}
lockCheck ${LOCKFILE}

source /etc/turbolab.it/mysql-${APP_NAME}.conf

fxTitle "Flush versions/asset..."
mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "DELETE from ${MYSQL_DB_NAME}.versions where ctype='asset'";
rm -rf ${PROJECT_DIR}var/versions/asset/*

fxTitle "Flush recyclebin..."
mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "TRUNCATE TABLE ${MYSQL_DB_NAME}.recyclebin";
rm -rf ${PROJECT_DIR}var/recyclebin/*

source ${SCRIPT_DIR}/script_end.sh
