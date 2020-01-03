OpenDKIM configuration
======================

To complete your configuration (replace turbolab.it with your own domain):

echo 'Greetings from your new, WEBSTACK.UP'ed server! This mail should be DKIM'ed!' | mail -s 'This is a DKIM test form your server' -a From:info@turbolab.it -a Cc:check-auth@verifier.port25.com me@gmail.com


OpenDKIM DNS
============

Add it to your DNS as:

* name/domain: default._domainkey.turbolab.it
* value: sudo cat /etc/opendkim/keys/turbolab.it/default.txt
