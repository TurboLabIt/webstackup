#!/bin/bash
clear

## Script name
SCRIPT_NAME=renew

## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo "  Let's Encrypt renew by  WEBSTACK.UP - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

##
certbot renew && systemctl restart nginx

## =========== The End ===========
printTitle "Time took"
echo "$((($(date +%s)-$TIME_START)/60)) min."

printTitle "The End"
echo $(date)
echo "$FRAME"
