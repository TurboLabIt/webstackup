# webstackup
An unattended bash script for Ubuntu to setup a  PHP-based web server stack for production or development.

# How to

1. Clone the script:

````shell
sudo -H -s
wget -O setup.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) && bash setup.sh && rm setup.sh
````

2. Choose the components

````shell
cp /usr/local/turbolab.it/webstackup/webstackup.default.conf /etc/turbolab.it/webstackup.conf && nano /etc/turbolab.it/webstackup.conf
````

3. Deploy the stack:

````shell
bash /usr/local/turbolab.it/webstackup/script/deploy_new_server.sh
````

Your stack is now ready. Happy coding!

# Run the manager

`webstackup`
