#!/usr/bin/env bash
### PHP SESSIONS REGENERATOR BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/php/sessions-folder-regenerate.sh

source /usr/local/turbolab.it/webstackup/script/base.sh

fxHeader "📂 PHP sessions folder regenerator"
rootCheck

if [ ! -d "/var/lib/php/sessions" ]; then
  fxCatastrophicError "/var/lib/php/sessions is missing!"
fi

nginx -t
if [ $? -neq 0 ]; then
  fxCatastrophicError "NGINX config is failing, cannot proceed"
fi


fxTitle "Stopping web services..."
service nginx stop
service $PHP_FPM stop
fxCountdown 5


fxTitle "Sessions folder re-generation..."
mv /var/lib/php/sessions /var/lib/php/sessions_old
mkdir /var/lib/php/sessions
chown root:root /var/lib/php/sessions
chmod 1733 /var/lib/php/sessions

echo ""
ls -l /var/lib/php/
echo ""
ls -l /var/lib/php/sessions


fxTitle "Starting web services..."
service $PHP_FPM start
service nginx start


fxTitle "Cleaning up..."
# Deletes in the background, strictly yielding to other disk I/O
ionice -c 3 rm -rf /var/lib/php/sessions_old &


fxEndFooter
