#!/usr/bin/env bash
### AUTOMATIC VARNISH INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/varnish/install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/varnish/install.sh | sudo VARNISH_VER=7.6 bash
#
# Based on: https://turbolab.it/4221 | https://www.varnish-software.com/developers/tutorials/installing-varnish-ubuntu/

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 VARNISH installer"
rootCheck


## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ -f "${WSU_DIR}setup-if-stale.sh" ]; then
  "${WSU_DIR}setup-if-stale.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh | sudo bash
fi

source "${WSU_DIR}script/base.sh"


fxTitle "Removing any old previous instance..."
fxInfo "Note: this will display some errors if Varnish is not installed yet."
fxInfo "This is expected, don't freak out"
apt purge --auto-remove 'varnish*' -y
rm -rf /etc/varnish /var/log/varnish


fxTitle "Installing prerequisites..."
apt update -qq
apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y

fxTitle "Installing additional utilities..."
apt install software-properties-common openssl zip unzip nano -y


fxTitle "Selecting the version..."
if [ -z "${VARNISH_VER}" ]; then

  VARNISH_VER=7.6
  fxImportantMessage "VARNISH_VER is not set - defaulting to Varnish ${VARNISH_VER}"

else

  fxInfo "Selecting the configured VARNISH_VER version, Varnish ${VARNISH_VER}"
fi


fxTitle "Import the official varnish signing key..."
curl -L https://packagecloud.io/varnishcache/varnish${VARNISH_VER//./}/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/varnish-archive-keyring.gpg >/dev/null

fxTitle "Creating the apt source file..."
. /etc/os-release
echo "deb [signed-by=/usr/share/keyrings/varnish-archive-keyring.gpg] \
https://packagecloud.io/varnishcache/varnish${VARNISH_VER//./}/$ID/ $VERSION_CODENAME main" | sudo tee /etc/apt/sources.list.d/varnish.list

fxTitle "Set up repository pinning to prefer our packages over distribution-provided ones..."
echo -e "Package: varnish varnish-*\nPin: release o=packagecloud.io/varnishcache/*\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99varnish

fxTitle "apt install varnish..."
apt update -qq
apt install varnish -y


fxTitle "Installing the customized default.vcl..."
rm -f /etc/varnish/default.vcl
cp ${WSU_DIR}my-app-template/config/custom/varnish.vcl /etc/varnish/default.vcl
sed -i '0,/^# Based on/{/^# Based on/!d}' /etc/varnish/default.vcl


fxTitle "Generating the secret..."
dd if=/dev/random of=/etc/varnish/secret count=1 bs=128
chown vcache /etc/varnish/secret
chmod 0600 /etc/varnish/secret


fxTitle "First Varnish restart..."
VARNISH_OUTPUT="$(varnishd -C -f /etc/varnish/default.vcl 2>&1)"

if [ $? -eq 0 ]; then

  service varnish restart
  fxOK "Looking good!"
  
else

  fxCatastrophicError "${VARNISH_OUTPUT}" proceed
fi


fxTitle "Stopping Varnish (to set its dir to ramdrive)..."
service varnish stop


fxTitle "Clearing the on-drive dir..."
rm -rf /var/lib/varnish/*
touch "/var/lib/varnish/ALERT! You're looking at the DISK! The ramdrive is NOT mounted!"


fxTitle "Preparing the ramdrive (tempfs)..."
## 📚 https://vinyl-cache.org/docs/trunk/installation/platformnotes.html#on-linux-use-tmpfs-for-the-workdir
if grep -q "/var/lib/varnish" "/etc/fstab"; then
    fxInfo "Varnish entry already exists in /etc/fstab. Skipping 🦘"
else
    fxInfo "Adding Varnish ramdrive to /etc/fstab..."

    cat <<EOT >> "/etc/fstab"

## Varnish ramdrive (webstackup)
tmpfs   /var/lib/varnish    tmpfs   rw,size=1G,mode=0750,huge=never    0  0
EOT
    
    fxOK "Entry added successfully."
fi


systemctl daemon-reload
mount -a


fxTitle "Final Varnish restart..."
VARNISH_OUTPUT="$(varnishd -C -f /etc/varnish/default.vcl 2>&1)"

if [ $? -eq 0 ]; then

  service varnish restart
  fxOK "Looking good!"

else

  fxCatastrophicError "${VARNISH_OUTPUT}" proceed
fi



fxTitle "Enabling Varnish integration with NGINX..."
if [ ! -d /etc/nginx/ ]; then

  fxWarning "NGINX not installed, skipping 🦘"

else

  fxLink "${WEBSTACKUP_CONFIG_DIR}nginx/04_global_ip_forwarding.conf" /etc/nginx/conf.d/04_global_ip_forwarding.conf
  fxLink "${WEBSTACKUP_CONFIG_DIR}nginx/varnish.conf" /etc/nginx/varnish.conf

  fxTitle "Final Nginx restart..."
  nginx -t && service nginx restart
fi


fxEndFooter
