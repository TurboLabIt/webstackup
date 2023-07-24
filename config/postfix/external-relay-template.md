````shell
sudo apt update && sudo apt install nano -y && \
  sudo nano /etc/postfix/main.cf && sudo nano /etc/postfix/sasl_passwd && \
  sudo postmap /etc/postfix/sasl_passwd && \
  chown root:root /etc/postfix/sasl_passw* && chmod u=rw,go= /etc/postfix/sasl_passw* && \
  sudo service postfix restart && sudo service postfix status && \
  echo "Test from $(hostname) relayed via 3rd-party" | mail -s "Hello, this is $(hostname)!" -a FROM:info@my-test-app.com me@my-domain.com && \
  sleep 10 && sudo tail -n 25 /var/log/mail.log

````

## /etc/postfix/main.cf

````
## Send via 3rd-party relay server by WEBSTACK.UP
#================================================
relayhost = [smtp.gmail.com]:587
# relayhost = [smtp-out.mailserver.it]:25
smtp_use_tls = yes
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_sasl_security_options =
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd

````

## /etc/postfix/sasl_passwd

````
[smtp.gmail.com]:587 username@gmail.com:password
#[smtp-out.mailserver.it]:25 username@mailserver.it:password

````
