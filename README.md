# webstackup
An unattended bash script for Ubuntu to setup a  PHP-based web server stack for production or development.

# How to

1. Clone the script:

````
sudo -H -s
wget -O setup.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) && bash setup.sh && rm setup.sh
````

2. Deploy the stack:

````
bash /usr/local/turbolab.it/webstackup/script/deploy_new_server.sh
````

3. Your stack is now ready. Happy coding!

# Run the manager

`webstackup`
