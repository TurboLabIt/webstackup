````shell
sudo tail -f /var/log/mail.log

````

````shell
sudo apt update && sudo apt install curl -y && \
  sudo curl -o /tmp/email-test.sh https://github.com/TurboLabIt/webstackup/raw/refs/heads/master/script/mail/send-test-email.sh && \
  bash /tmp/email-test.sh sender@example.com recipient@example.com fast && \
  sudo rm /tmp/email-test.sh

````
