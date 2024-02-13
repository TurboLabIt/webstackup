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
