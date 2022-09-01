#!/usr/bin/env bash
### AUTOMATIC MYSQL TUNER BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/mysql/mysqltuner.sh?$(date +%s) | sudo bash
#

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🎚️ MySQL Tuner"
rootCheck

# https://github.com/major/MySQLTuner-perl#downloadinstallation #
#################################################################

MYSQLTUNER_DATA_DIR=/var/lib/mysqltuner/
mkdir ${MYSQLTUNER_DATA_DIR}

fxTitle "Install/update..."
curl -o ${MYSQLTUNER_DATA_DIR}mysqltuner.pl https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl
curl -o ${MYSQLTUNER_DATA_DIR}basic_passwords.txt https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt
curl -o ${MYSQLTUNER_DATA_DIR}vulnerabilities.csv https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv

source /etc/turbolab.it/mysql.conf
perl ${MYSQLTUNER_DATA_DIR}mysqltuner.pl --user "$MYSQL_USER" --pass "$MYSQL_PASSWORD"

fxEndFooter
