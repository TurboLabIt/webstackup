#!/bin/bash

for SERVICE_NAME in "nginx" "php7.3-fpm" "postfix" "opendkim" "mysql"
do
	echo "${SERVICE_NAME} is stopping..."
	sudo service ${SERVICE_NAME} stop
done


echo ""
echo "All done, cooling down before restart.."
echo ""
sleep 2


for SERVICE_NAME in "mysql" "opendkim" "postfix" "php7.3-fpm" "nginx"
do
	echo "${SERVICE_NAME} is starting..."
	sudo service ${SERVICE_NAME} start
done

echo ""
echo "Reload completed!"
echo ""
