#!/usr/bin/env bash
### AUTOMATIC MYSQL TUNER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/mysql/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/mysqltuner.sh?$(date +%s) | sudo bash
#
# Based on https://github.com/major/MySQLTuner-perl#downloadinstallation

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 MySQL Tuner installer"
rootCheck

MYSQLTUNER=/usr/local/bin/mysqltuner
MYSQLTUNER_DATA_DIR=/var/lib/mysqltuner/
mkdir -p ${MYSQLTUNER_DATA_DIR}

fxTitle "💿 Install/update..."
curl -o ${MYSQLTUNER} https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl
chmod u=rwx,go=rx ${MYSQLTUNER}

curl -o ${MYSQLTUNER_DATA_DIR}basic_passwords.txt https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt
curl -o ${MYSQLTUNER_DATA_DIR}vulnerabilities.csv https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv

MYSQLTUNER_WSU=/usr/local/turbolab.it/webstackup/script/mysql/mysqltuner.sh
if [ -f ${MYSQLTUNER_WSU} ]; then
  fxLinkBin $MYSQLTUNER_WSU zzmysqltuner
fi

fxTitle "🎚️ Running..."
source /etc/turbolab.it/mysql.conf
${MYSQLTUNER} --user "$MYSQL_USER" --pass "$MYSQL_PASSWORD" --color --cvefile=${MYSQLTUNER_DATA_DIR}vulnerabilities.csv

fxEndFooter
