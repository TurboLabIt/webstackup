#!/bin/bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "MySQL Tuner"
rootCheck

source /etc/turbolab.it/mysql.conf
mysqltuner --user $MYSQL_USER --pass $MYSQL_PASSWORD

printMessage "MySQL Tuner is done"
