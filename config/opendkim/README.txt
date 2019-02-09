OpenDKIM configuration
======================

To complete your configuration (replace turbolab.it with your own domain):

sudo mkdir -p /etc/opendkim/keys/turbolab.it && \
sudo opendkim-genkey -D /etc/opendkim/keys/turbolab.it/ -d turbolab.it -s default && \
sudo chown -R opendkim:opendkim /etc/opendkim/keys && \
sudo nano /etc/opendkim/KeyTable && \
sudo nano /etc/opendkim/SigningTable && \
echo "" && \
echo '========= KeyTable =========' && \
sudo cat /etc/opendkim/KeyTable && \
echo "" && \
echo '========= SigningTable =========' && \
sudo cat /etc/opendkim/SigningTable && \
echo "" && \
sudo service opendkim restart && \
sudo systemctl --no-pager status opendkim && \
echo 'Greetings from your new, WEBSTACK.UP'ed server! This mail should be DKIM'ed!' | mail -s 'This is a DKIM test form your server' -a From:info@turbolab.it -a Cc:check-auth@verifier.port25.com me@gmail.com


OpenDKIM DNS
============

Add it to your DNS as:

* name/domain: default._domainkey.turbolab.it
* value: sudo cat /etc/opendkim/keys/turbolab.it/default.txt
