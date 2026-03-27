<p align="center">
  <img width="256" src="https://i.postimg.cc/xd4SgKTt/wsu-icon.png" />
</p>

An unattended bash script for Ubuntu to setup a PHP-based web server stack for production or development.


## Quick startup guide

Install it:

````shell
sudo apt update && sudo apt install curl -y && \
  curl -sL wsu.turbolab.it | sudo bash
````


Access the features:

````shell
webstackup
````


To choose the components and provision your NEW server:

````shell
sudo -H bash /usr/local/turbolab.it/webstackup/script/deploy_new_server.sh
````
