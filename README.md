# webstackup
An unattended bash script for Ubuntu to setup a  PHP-based web server stack for production or development.

# How to

`sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/webstackup.sh | sudo bash`

# Post-setup ideas (optional)

`sudo nano ~/.ssh/authorized_keys`

[Rif: SSH senza password](https://turbolab.it/653)

`sudo sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config`

[Rif: SSH: impedire il login tramite password](https://turbolab.it/654)
