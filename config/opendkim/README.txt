OpenDKIM configuration
======================

To complete your configuration (replace turbolab.it with your own domain):

sudo mkdir -p /etc/opendkim/keys/turbolab.it
sudo opendkim-genkey -D /etc/opendkim/keys/turbolab.it/ -d turbolab.it -s default
sudo chown -R opendkim:opendkim /etc/opendkim/keys
sudo nano /etc/opendkim/KeyTable /etc/opendkim/SigningTable
sudo cat /etc/opendkim/KeyTable
sudo cat /etc/opendkim/SigningTable
sudo service opendkim restart
sudo service opendkim status


Add it to your DNS as:

* name/domain: default._domainkey.turbolab.it
* value: sudo cat /etc/opendkim/keys/turbolab.it/default.txt
