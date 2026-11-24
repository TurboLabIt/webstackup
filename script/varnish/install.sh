#!/usr/bin/env bash
### AUTOMATIC VARNISH INSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/varnish/install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/varnish/install.sh | sudo VARNISH_VER=9.1 bash
#
# Based on: https://turbolab.it/4221 | https://www.varnish.org/docs/install-guide/install-debian-ubuntu/

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


fxTitle "Selecting the version..."
if [ -z "${VARNISH_VER}" ]; then

  VARNISH_VER=9.1
  fxImportantMessage "VARNISH_VER is not set - defaulting to Varnish ${VARNISH_VER}"

else

  fxInfo "Selecting the configured VARNISH_VER version, Varnish ${VARNISH_VER}"
fi


## Varnish Software's repo: a single repo with every series. packagecloud.io/varnishcache, the old project's one,
## has been frozen since the Varnish Cache / Vinyl Cache split (Sep 2025): nothing after Ubuntu 24.04 or Debian 12
WSU_VARNISH_REPO=https://packages.varnish-software.com/varnish/
. /etc/os-release

fxTitle "Checking that Varnish ${VARNISH_VER} is available for ${ID} ${VERSION_CODENAME}..."
## before removing anything: asking for a version that isn't there would leave the server without Varnish
WSU_VARNISH_AVAILABLE=$(curl -fsSL "${WSU_VARNISH_REPO}${ID}/dists/${VERSION_CODENAME}/main/binary-$(dpkg --print-architecture)/Packages.gz" | gunzip -c 2>/dev/null | awk '/^Package: /{ PKG=$2 } PKG == "varnish" && /^Version: /{ print $2 }' | sort -uV)

if [ -z "${WSU_VARNISH_AVAILABLE}" ]; then
  fxCatastrophicError "${WSU_VARNISH_REPO} has no Varnish for ${ID} ${VERSION_CODENAME}"
fi

if ! grep -q "^${VARNISH_VER//./\\.}\." <<< "${WSU_VARNISH_AVAILABLE}"; then
  fxCatastrophicError "Varnish ${VARNISH_VER} is not available for ${ID} ${VERSION_CODENAME}. Available: $(cut -d. -f1,2 <<< "${WSU_VARNISH_AVAILABLE}" | sort -uV | tr '\n' ' ')"
fi

fxOK "Varnish $(grep "^${VARNISH_VER//./\\.}\." <<< "${WSU_VARNISH_AVAILABLE}" | tail -n 1)"


fxTitle "Removing any old previous instance..."
fxInfo "Note: this will display some errors if Varnish is not installed yet."
fxInfo "This is expected, don't freak out"
if [ -f "${WEBSTACKUP_SCRIPT_DIR}varnish/remove.sh" ]; then
  bash "${WEBSTACKUP_SCRIPT_DIR}varnish/remove.sh"
else
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/varnish/remove.sh | sudo bash
fi

## a failed removal leaves dpkg broken: every apt command below would fail too
if [ $? -ne 0 ]; then
  fxCatastrophicError "Removing the previous Varnish instance failed"
fi


fxTitle "Installing prerequisites..."
fxAptUpdate
apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y

fxTitle "Installing additional utilities..."
apt install software-properties-common openssl zip unzip nano -y


fxTitle "Importing the Varnish Software signing key..."
curl -fsSL ${WSU_VARNISH_REPO}varnish.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/varnish-archive-keyring.gpg >/dev/null

fxTitle "Creating the apt source file..."
echo "deb [signed-by=/usr/share/keyrings/varnish-archive-keyring.gpg] ${WSU_VARNISH_REPO}${ID} ${VERSION_CODENAME} main" | sudo tee /etc/apt/sources.list.d/varnish.list

fxTitle "Pinning Varnish ${VARNISH_VER}..."
## the repo carries every series: unpinned, apt would install the newest one, and a later upgrade would jump to the next.
## A single "Pin:" line: apt ignores all of them but the last one
echo -e "Package: varnish varnish-*\nPin: version ${VARNISH_VER}.*\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99varnish

fxTitle "apt install varnish..."
fxAptUpdate 0
apt install varnish -y

## e.g. a failed apt update would silently install the distro's own, older, Varnish instead
WSU_VARNISH_INSTALLED=$(dpkg-query -W -f='${Version}' varnish 2>/dev/null)
if [[ "${WSU_VARNISH_INSTALLED}" != "${VARNISH_VER}."* ]]; then
  fxCatastrophicError "Expected Varnish ${VARNISH_VER}, got ##${WSU_VARNISH_INSTALLED:-nothing}##"
fi


fxTitle "Installing the customized default.vcl..."
rm -f /etc/varnish/default.vcl
cp ${WSU_DIR}my-app-template/config/custom/varnish.vcl /etc/varnish/default.vcl
sed -i '0,/^# Based on/{/^# Based on/!d}' /etc/varnish/default.vcl


fxTitle "Generating the secret..."
dd if=/dev/random of=/etc/varnish/secret count=1 bs=128
chown vcache /etc/varnish/secret
chmod 0600 /etc/varnish/secret


WSU_VARNISH_SERVICE_OVERRIDE_PATH=/etc/systemd/system/varnish.service.d/
fxTitle "Linking the custom service file from ###${WSU_VARNISH_SERVICE_OVERRIDE_PATH}###..."
sudo mkdir -p $WSU_VARNISH_SERVICE_OVERRIDE_PATH
sudo ln -s ${WEBSTACKUP_CONFIG_DIR}varnish/varnish.service ${WSU_VARNISH_SERVICE_OVERRIDE_PATH}30-webstackup.conf
sudo systemctl daemon-reload
sudo systemctl show --no-pager -p FragmentPath -p DropInPaths varnish


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
