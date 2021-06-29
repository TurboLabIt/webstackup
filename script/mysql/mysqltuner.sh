#!/bin/bash
clear

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "MySQL Tuner"
rootCheck

source /etc/turbolab.it/mysql.conf
mysqltuner --host 127.0.0.1 --user $MYSQL_USER --pass $MYSQL_PASSWORD

printMessage "MySQL Tuner is done"
