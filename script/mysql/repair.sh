#!/usr/bin/env bash
### AUTOMATIC MYSQL CHECK AND REPAIR BY WEBSTACK.UP
#

## THIS SCRIPT WAS MADE IN A RUSH AND NEEDS SOME LOVE

source /etc/turbolab.it/mysql.conf

mysqlcheck -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" --all-databases --auto-repair --medium-check
mysqlcheck -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" --all-databases --check-upgrade
mysqlcheck -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" --all-databases --optimize
