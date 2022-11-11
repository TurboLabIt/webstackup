# webstackup

An unattended bash script for Ubuntu to setup a PHP-based web server stack for production or development.


## How to

sudo:

````shell
sudo -H -s

````

Clone the script, choose the components, run it

````shell
wget https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) -O - | bash && cp /usr/local/turbolab.it/webstackup/webstackup.default.conf /etc/turbolab.it/webstackup.conf && nano /etc/turbolab.it/webstackup.conf && bash /usr/local/turbolab.it/webstackup/script/deploy_new_server.sh

````

Your stack is now ready. Happy coding!


## Run the manager

`webstackup`
