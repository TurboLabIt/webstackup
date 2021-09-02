#!/bin/bash
clear

source "$(dirname "$(readlink -f "$0")")/base.sh"

printHeader "WEBSTACK.UP"
rootCheck


printMessage "Loading default config..."
source ${WEBSTACKUP_INSTALL_DIR}webstackup.default.conf

## Default config error!
if [[ $WEBSTACKUP_ENABLED != 1 ]]; then

    catastrophicError "Default config file not available or script disabled"
fi


## Config file from CLI
CONFIGFILE_FULLPATH=$1
if [ ! -z "$CONFIGFILE_FULLPATH" ] && [ ! -f "$CONFIGFILE_FULLPATH" ]; then

    catastrophicError "Config file not found!
Please check if the following file exists and is accessible:
    
$CONFIGFILE_FULLPATH"

fi


## Config file from CLI OK
if [ ! -z "$CONFIGFILE_FULLPATH" ]; then
    
    printTitle "Importing custom options"
    source "$CONFIGFILE_FULLPATH"
    
    printMessage "Custom options imported from $CONFIGFILE_FULLPATH"
    
else

    CONFIGFILE_NAME=webstackup.conf
    CONFIGFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_NAME
    CONFIGFILE_FULLPATH_DIR=${SCRIPT_DIR}$CONFIGFILE_NAME

    for CONFIGFILE_FULLPATH in "$CONFIGFILE_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_DIR"
    do
        if [ -f "$CONFIGFILE_FULLPATH" ]; then
        
            source "$CONFIGFILE_FULLPATH"
        fi
    done
fi


printTitle "Installing WEBSTACK.UP..."
if [ $INSTALL_WEBSTACKUP = 1 ]; then

    printMessage "Installing dependencies..."
    apt update -qq
    apt install git software-properties-common gnupg2 dialog htop screen openssl -y -qq
    
    if [ ! -d "$WEBSTACKUP_INSTALL_DIR" ]; then
        printMessage "Installing..."
        mkdir -p "$WEBSTACKUP_INSTALL_DIR_PARENT"
        git clone https://github.com/TurboLabIt/webstackup.git "$WEBSTACKUP_INSTALL_DIR"
    else
        printMessage "Updating..."
        git -C "$WEBSTACKUP_INSTALL_DIR" pull
    fi
    
    printMessage "Creating a folder for the autogenerated files..."
    mkdir -p "${WEBSTACKUP_AUTOGENERATED_DIR}"
    >"${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"

    printMessage "Setting up the webstackup command..."
    if [ ! -e "/usr/bin/webstackup" ]; then
    
        ln -s ${WEBSTACKUP_INSTALL_DIR}script/webstackup.sh /usr/bin/webstackup
    fi
    
    printMessage "Creating a new user account (the deployer)..."
    id -u webstackup &>/dev/null || useradd -G www-data webstackup --shell=/bin/false --create-home
    printMessage $(cat /etc/passwd | grep webstackup)
    
    printMessage "Generating an SSH key..."
    DEPLOYER_SSH_DIR=/home/webstackup/.ssh/
    mkdir -p "${DEPLOYER_SSH_DIR}"
    ssh-keyscan -t rsa github.com > "${DEPLOYER_SSH_DIR}known_hosts"
    touch "${DEPLOYER_SSH_DIR}config"
    chown webstackup:webstackup "${DEPLOYER_SSH_DIR}" -R
    
    chmod u=rwX,go= "${DEPLOYER_SSH_DIR}" -R
    sudo -u webstackup -H ssh-keygen -t rsa -f "${DEPLOYER_SSH_DIR}id_rsa" -N ''
    
    chmod u=rX,go= "${DEPLOYER_SSH_DIR}" -R
    chmod u=rw,go= "${DEPLOYER_SSH_DIR}known_hosts"
    
    sudo -u webstackup -H git config --global user.name "webstack.up"
    sudo -u webstackup -H git config --global user.email "info@webstack.up"
    
    printMessage "Keep SSH alive..."
    cp "${WEBSTACKUP_INSTALL_DIR}config/ssh/keepalive.conf" /etc/ssh/sshd_config.d/

    sleep 5

else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Set the timezone..."
if [ ! -z "$INSTALL_TIMEZONE" ]; then 

  timedatectl set-timezone $INSTALL_TIMEZONE
  service syslog restart
  service cron restart
fi


printTitle "Installing NGINX..."
if [ $INSTALL_NGINX = 1 ]; then
    
    printMessage "Removing previous version (if any)"
    apt purge --auto-remove nginx* -y -qq
  
  source ${WEBSTACKUP_INSTALL_DIR}script/nginx/install.sh

    ## Create self-signed, bogus certificates (so that we can disable plain-HTTP completely)
    source "${WEBSTACKUP_INSTALL_DIR}script/https/self-sign-generate.sh" localhost
    
    printMessage "Generating dhparam..."
    openssl dhparam -out "${WEBSTACKUP_AUTOGENERATED_DIR}dhparam.pem" 2048 > /dev/null

    printMessage "Generating the httpauth default file..."
    HTTPAUTH_FULLFILE=${WEBSTACKUP_AUTOGENERATED_DIR}httpauth_welcome

    echo -n 'wel:' > "$HTTPAUTH_FULLFILE"
    openssl passwd -apr1 'come' >> "$HTTPAUTH_FULLFILE"
    echo '' >> "$HTTPAUTH_FULLFILE"

    echo -n 'ben:' >> "$HTTPAUTH_FULLFILE"
    openssl passwd -apr1 'venuto' >> "$HTTPAUTH_FULLFILE"
    echo '' >> "$HTTPAUTH_FULLFILE"

    printMessage "Ready-to-use HTTP Auth will be:
User: wel | Pass: come
User: ben | Pass: venuto"
    
    printMessage "Moving the original config outta way..."
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d_default_original_backup.conf

    printMessage "Upgrade all to HTTPS..."
    ln -s "${WEBSTACKUP_INSTALL_DIR}config/nginx/00_global_https_upgrade_all.conf" /etc/nginx/conf.d/

    printMessage "Disable the default website..."
    ln -s "${WEBSTACKUP_INSTALL_DIR}config/nginx/05_global_default_vhost_disable.conf" /etc/nginx/conf.d/
    
    printMessage "Enabling the http-block level functionality"
    ln -s "${WEBSTACKUP_INSTALL_DIR}config/nginx/02_global_http_level.conf" /etc/nginx/conf.d/
    
    systemctl restart nginx
    systemctl  --no-pager status nginx
    nginx -t
    
    WWW_DATA_HOME=/var/www/
    if [ ! -d "${WWW_DATA_HOME}" ]; then
    
        printMessage "Creating the www-data home..."
        mkdir -p "${WWW_DATA_HOME}"
    else    
        printMessage "www-data home already exists, skipping"
    fi
    
    printMessage "Setting the ownership for the whole tree..."
    chown www-data:www-data "${WWW_DATA_HOME}" -R

    printMessage "SetGID on the root directory only"
    # Any files created in the directory will have their group set to www-data
    chmod g+s "${WWW_DATA_HOME}"

    printMessage "SetGID on the directories inside..."
    find "${WWW_DATA_HOME}" -type d -exec chmod g+s {} \;

    printMessage "Setting the permissions for the whole tree..."
    chmod u=rwX,g=rX,o= "${WWW_DATA_HOME}" -R
    
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing PHP-CLI and PHP-FPM..."
if [ $INSTALL_PHP = 1 ]; then
    
    printMessage "Removing previous version (if any)"
    apt purge --auto-remove php* -y -qq
    
    printMessage "Setting up ondrej/php"
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
    apt update -qq

    printMessage "Installing..."
    apt install php${PHP_VER}-fpm php${PHP_VER}-cli php${PHP_VER}-common php${PHP_VER}-mbstring php${PHP_VER}-gd php${PHP_VER}-intl php${PHP_VER}-xml php${PHP_VER}-mysql php${PHP_VER}-zip php${PHP_VER}-curl -y -qq
    
    echo "PHP_VER=${PHP_VER}" >> "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"
    echo "PHP_FPM=php${PHP_VER}-fpm" >> "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"
    echo "PHP_CLI=/usr/bin/php${PHP_VER}" >> "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"
    
    printMessage "Activating custom php.ini..."    
    ln -s  "${WEBSTACKUP_INSTALL_DIR}config/php/php-custom.ini" /etc/php/${PHP_VER}/fpm/conf.d/30-webstackup-custom.ini
    ln -s  "${WEBSTACKUP_INSTALL_DIR}config/php/php-custom.ini" /etc/php/${PHP_VER}/cli/conf.d/30-webstackup-custom.ini
    
    printMessage "Set timezone to Italy..."
    ln -s  "${WEBSTACKUP_INSTALL_DIR}config/php/timezone-italy.ini" /etc/php/${PHP_VER}/fpm/conf.d/30-webstackup-timezone-italy.ini
    ln -s  "${WEBSTACKUP_INSTALL_DIR}config/php/timezone-italy.ini" /etc/php/${PHP_VER}/cli/conf.d/30-webstackup-timezone-italy.ini
  
  printMessage "Disable cgi.fix_pathinfo..."
  ln -s  "${WEBSTACKUP_INSTALL_DIR}config/php/no-cgi.fix_pathinfo.ini" /etc/php/${PHP_VER}/fpm/conf.d/30-no-cgi.fix_pathinfo.ini
    
    printMessage "Activating custom php-fpm pool settings..."
    if [ "$INSTALLED_RAM" -gt "6000" ]; then
    
        echo "RAM: ${INSTALLED_RAM}: using fpm-pool-32GB.conf"
        ln -s  "${WEBSTACKUP_INSTALL_DIR}config/php/fpm-pool-32GB.conf" /etc/php/${PHP_VER}/fpm/pool.d/zz-webstackup-fpm-pool-32GB.conf
        
    else
    
        echo "RAM: ${INSTALLED_RAM}: this is a small server! Using fpm-pool-1GB.conf"
        ln -s  "${WEBSTACKUP_INSTALL_DIR}config/php/fpm-pool-1GB.conf" /etc/php/${PHP_VER}/fpm/pool.d/zz-webstackup-fpm-pool-1GB.conf
    fi
    
    printMessage "Assigning the nginx user to www-data group..."
    usermod -a -G www-data nginx
    systemctl restart nginx
    
    systemctl restart php${PHP_VER}-fpm
    systemctl  --no-pager status php${PHP_VER}-fpm
    
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing MYSQL..."
if [ $INSTALL_MYSQL = 1 ]; then
    
    printMessage "Removing previous version (if any)"
    apt purge --auto-remove mysql* -y -qq

    printMessage "Setting up the repo..."
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5072E1F5

    touch /etc/apt/sources.list.d/webstackup.mysql.list
    echo "### webstackup" >> /etc/apt/sources.list.d/webstackup.mysql.list
    echo "deb http://repo.mysql.com/apt/ubuntu/ $(lsb_release -sc) mysql-${MYSQL_VER}" >> /etc/apt/sources.list.d/webstackup.mysql.list
    echo "deb-src http://repo.mysql.com/apt/ubuntu/ $(lsb_release -sc) mysql-${MYSQL_VER}" >> /etc/apt/sources.list.d/webstackup.mysql.list
    echo "deb http://repo.mysql.com/apt/ubuntu/ $(lsb_release -sc) mysql-tools" >> /etc/apt/sources.list.d/webstackup.mysql.list
    
    printMessage "Generating a random MySQL root password..."
    MYSQL_ROOT_PASSWORD="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 19)"
    debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password ${MYSQL_ROOT_PASSWORD}"
    debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password ${MYSQL_ROOT_PASSWORD}"
    debconf-set-selections <<< "mysql-community-server mysql-server/default-auth-override select"

    printMessage "Installing..."
    apt update -qq
    apt install mysql-server mysql-client -y -qq
    
    printMessage "Enabling the custom config..."
    cp "${WEBSTACKUP_INSTALL_DIR}config/mysql/mysql.cnf" "/etc/mysql/mysql.conf.d/webstackup.cnf"
    sudo chmod u=rw,go=r "/etc/mysql/mysql.conf.d/*.cnf"
    
    MYSQL_CREDENTIALS_DIR="/etc/turbolab.it/"
    MYSQL_CREDENTIALS_FULLPATH="${MYSQL_CREDENTIALS_DIR}mysql.conf"
    
    if [ ! -e "${MYSQL_CREDENTIALS_FULLPATH}" ]; then
    
        printMessage "Writing MySQL root credentials to ${MYSQL_CREDENTIALS_FULLPATH}..."
        mkdir -p "$MYSQL_CREDENTIALS_DIR"
        echo "MYSQL_USER='root'" > "${MYSQL_CREDENTIALS_FULLPATH}"
        echo "MYSQL_PASSWORD='$MYSQL_ROOT_PASSWORD'" >> "${MYSQL_CREDENTIALS_FULLPATH}"
        
        chown root:root "${MYSQL_CREDENTIALS_FULLPATH}"
        chmod u=r,go= "${MYSQL_CREDENTIALS_FULLPATH}"
    fi
    
    printMessage "$(cat "${MYSQL_CREDENTIALS_FULLPATH}")" 
    
    systemctl restart mysql
    systemctl  --no-pager status mysql
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing COMPOSER..."
if [ $INSTALL_COMPOSER = 1 ]; then

    printMessage "Downloading..."
    COMPOSER_EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    COMPOSER_ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    
    if [ "$COMPOSER_EXPECTED_SIGNATURE" != "$COMPOSER_ACTUAL_SIGNATURE" ]; then
    
        catastrophicError "Composer signature doesn't match! Abort! Abort!"

Expec. hash: ### ${COMPOSER_EXPECTED_SIGNATURE}
Actual hash: ### ${COMPOSER_ACTUAL_SIGNATURE}"
    fi
    
    printMessage "Installing..."
    php composer-setup.php --filename=composer --install-dir=/usr/local/bin
    php -r "unlink('composer-setup.php');"
    
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing SYMFONY"
if [ $INSTALL_SYMFONY = 1 ]; then
    
    printMessage "Installing..."
    wget https://get.symfony.com/cli/installer -O - | bash
    mv /root/.symfony/bin/symfony /usr/local/bin/symfony
    
    printMessage "$(symfony -V)"
    
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing ZZUPDATE..."
if [ $INSTALL_ZZUPDATE = 1 ]; then

    curl -s https://raw.githubusercontent.com/TurboLabIt/zzupdate/master/setup.sh | sudo bash
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing ZZMYSQLDUMP"
if [ $INSTALL_ZZMYSQLDUMP = 1 ]; then

    curl -s https://raw.githubusercontent.com/TurboLabIt/zzmysqldump/master/setup.sh | sudo bash
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing XDEBUG..."
if [ $INSTALL_XDEBUG = 1 ]; then

    printMessage "Installing..."
    apt install php-xdebug -y -qq
    
    printMessage "Activating custom xdebug config..."
    XDEBUG_CONFIG_FILE_FULLPATH="${WEBSTACKUP_INSTALL_DIR}config/php/xdebug.ini"    
    ln -s "$XDEBUG_CONFIG_FILE_FULLPATH" /etc/php/${PHP_VER}/fpm/conf.d/30-webstackup-xdebug.ini
    ln -s "$XDEBUG_CONFIG_FILE_FULLPATH" /etc/php/${PHP_VER}/cli/conf.d/30-webstackup-xdebug.ini
    
    systemctl restart php${PHP_VER}-fpm
    sleep 5

else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing LET'S ENCRYPT..."
if [ $INSTALL_LETSENCRYPT = 1 ]; then
    
    printMessage "Installing..."
    apt install certbot -y -qq
    
    printMessage "$(certbot --version)"

    service cron restart
    
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing POSTFIX and OPENDKIM"
if [ $INSTALL_POSTFIX = 1 ]; then

    printMessage "Installing..."
    apt install postfix mailutils opendkim opendkim-tools -y -qq
    
    printMessage "Adding the postfix user to the opendkim group..."
    adduser postfix opendkim
    
    printMessage "Wiring together opendkim and postfix..."
    mkdir /var/spool/postfix/opendkim
    chown opendkim:postfix /var/spool/postfix/opendkim
    
    sed -i -e 's|^UMask|#UMask|g' /etc/opendkim.conf
    sed -i -e 's|^Socket|#Socket|g' /etc/opendkim.conf
    echo "" >>  /etc/opendkim.conf
    echo "" >>  /etc/opendkim.conf
    echo "" >>  /etc/opendkim.conf
    cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/opendkim_to_be_appended.conf" >> /etc/opendkim.conf
    
    echo "" >>  /etc/postfix/main.cf
    echo "" >>  /etc/postfix/main.cf
    echo "" >>  /etc/postfix/main.cf
    cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/postfix_to_be_appended.conf" >> /etc/postfix/main.cf
    
    sed -i -e 's|^SOCKET=|#SOCKET=|g' /etc/default/opendkim
    echo "" >> /etc/default/opendkim
    echo "" >> /etc/default/opendkim
    echo "" >> /etc/default/opendkim
    cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/opendkim-default_to_be_appended.conf" >> /etc/default/opendkim
    
    mkdir -p /etc/opendkim/keys
    
    cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/TrustedHosts" /etc/opendkim/TrustedHosts
    cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/KeyTable" /etc/opendkim/KeyTable
    cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/SigningTable" /etc/opendkim/SigningTable
    
    chown opendkim:opendkim /etc/opendkim/ -R
    chmod ug=rwX,o=rX /etc/opendkim/ -R
    chmod u=rwX,og=X /etc/opendkim/keys -R
    
    systemctl restart postfix
    systemctl restart opendkim
    
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing NTP..."
if [ $INSTALL_NTP = 1 ]; then

    printMessage "Installing..."
    apt install ntp -y -qq
    
    systemctl restart ntp
    systemctl  --no-pager status ntp
    
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Installing ZZALIAS..."
if [ $INSTALL_ZZALIAS = 1 ]; then

    curl -s https://raw.githubusercontent.com/TurboLabIt/zzalias/master/setup.sh | sudo bash
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTitle "Firewalling..."
if [ $INSTALL_UFW = 1 ]; then

    source "${WEBSTACKUP_INSTALL_DIR}script/firewall/persona-non-grata.sh"
    sleep 5
    
else
    
    printLightWarning "Skipped (disabled in config)"
fi

printTitle "Installing cron..."
cp "${WEBSTACKUP_INSTALL_DIR}config/cron/webstackup" /etc/cron.d/

printTitle "REBOOTING..."
if [ "$REBOOT" = "1" ] && [ "$INSTALL_ZZUPDATE" = 1 ]; then

    while [ $REBOOT_TIMEOUT -gt 0 ]; do
       echo -ne "$REBOOT_TIMEOUT\033[0K\r"
       sleep 1
       : $((REBOOT_TIMEOUT--))
    done
    zzupdate

elif [ "$REBOOT" = "1" ]; then

    while [ $REBOOT_TIMEOUT -gt 0 ]; do
       echo -ne "$REBOOT_TIMEOUT\033[0K\r"
       sleep 1
       : $((REBOOT_TIMEOUT--))
    done
    reboot

else
    
    printLightWarning "Skipped (disabled in config)"
fi


printTheEnd
