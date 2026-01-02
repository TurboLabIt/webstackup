````shell
sudo apt update && sudo apt install nano -y && \
  sudo touch /var/log/webstackup-email_transport_write-to-file.log && \
  sudo chown postfix:root /var/log/webstackup-email_transport_write-to-file.log && \
  sudo chmod u=rw,g=r,o= /var/log/webstackup-email_transport_write-to-file.log && \
  sudo nano /etc/postfix/main.cf && \
  sudo service postfix restart && sudo service postfix status && \
  echo "Test from $(hostname) with write-to-file" | mail -s "Hello, this is $(hostname)! I sent this one to none@none.com" -a FROM:info@my-test-app.com none@none.com && \
  sleep 10 && sudo tail -n 25 /var/log/mail.log && sudo tail -n 25 /var/log/webstackup-email_transport_write-to-file.log

````


## /etc/postfix/main.cf

````
## Write-to-file by WEBSTACKUP
##############################
wsu_write_to_file_transport unix  -      n       n       -       -       pipe
  flags=F user=postfix argv=/usr/local/turbolab.it/webstackup/script/mail/transport_write-to-file.sh

# Route every single email to our custom transport
default_transport = wsu_write_to_file_transport

# Ensure local delivery is also caught
relayhost =
````