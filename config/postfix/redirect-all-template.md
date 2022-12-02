````shell
sudo apt update && sudo apt install nano -y && \
  sudo nano /etc/postfix/main.cf && sudo nano /etc/postfix/virtual-regexp && \
  sudo postmap /etc/postfix/virtual-regexp && \
  sudo service postfix restart && sudo service postfix status && \
  echo "Test from $(hostname) relayed via 3rd-party" | mail -s "Hello, this is $(hostname)!" none@none.com && \
  sleep 10 && sudo tail -n 25 /var/log/mail.log

````

## /etc/postfix/main.cf

````
## Redirects by WEBSTACK.UP
###########################
virtual_alias_maps = regexp:/etc/postfix/virtual-regexp

````

## /etc/postfix/virtual-regexp

````
## redirect all
/.+@.+/ me@my-domain.com

````
