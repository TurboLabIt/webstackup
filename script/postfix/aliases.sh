#!/usr/bin/env bash

sudo nano /etc/postfix/virtual-regexp
sudo postmap /etc/postfix/virtual-regexp
sudo service postfix restart
sudo service postfix status

