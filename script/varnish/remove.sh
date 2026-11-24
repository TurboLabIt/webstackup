#!/usr/bin/env bash
### AUTOMATIC VARNISH UNINSTALLER BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/tree/master/script/varnish/remove.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/varnish/remove.sh | sudo bash
#
# It removes everything https://github.com/TurboLabIt/webstackup/tree/master/script/varnish/install.sh sets up.
# install.sh runs it before installing.


## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧹 Varnish Remover"
rootCheck


fxTitle "Stopping Varnish..."
service varnishncsa stop
service varnish stop


fxTitle "Unmounting the ramdrive..."
## this must come before the purge. The package postrm runs `rm -r /var/lib/varnish || exit 78`, and rm can't
## delete a mountpoint: the purge would fail midway, with the binaries already gone and the package stuck half-installed
if mountpoint -q /var/lib/varnish; then
  ## lazy fallback: any varnishlog/varnishstat still running keeps the ramdrive busy
  umount /var/lib/varnish || umount -l /var/lib/varnish
fi

if mountpoint -q /var/lib/varnish; then
  fxCatastrophicError "Can't unmount the ramdrive from /var/lib/varnish"
fi

## first the block added by install.sh, together with the blank line before it.
## Then any other line that install.sh would read as "the entry already exists"
sed -z -i -E 's|\n*## Varnish ramdrive \(webstackup\)\n[^\n]*/var/lib/varnish[^\n]*\n|\n|g' /etc/fstab
sed -i -e '\|/var/lib/varnish|d' -e '/^## Varnish ramdrive (webstackup)$/d' /etc/fstab


fxTitle "Removing Varnish..."
DEBIAN_FRONTEND=noninteractive apt purge --auto-remove 'varnish*' -y

## a package that was already half-installed (e.g. after a failed removal) only reaches "rc" on the first purge
if dpkg-query -W -f='${db:Status-Abbrev}\n' 'varnish*' 2>/dev/null | grep -q '^.c'; then
  DEBIAN_FRONTEND=noninteractive apt purge 'varnish*' -y
fi

if dpkg-query -W -f='${db:Status-Abbrev}\n' 'varnish*' 2>/dev/null | grep -qv '^.n'; then
  dpkg -l 'varnish*'
  fxCatastrophicError "Varnish is still installed"
fi


fxTitle "Removing config..."
rm -rf /etc/*varnish* /etc/default/varnish* /etc/init.d/varnish* /etc/logrotate.d/varnish*


fxTitle "Removing logs..."
rm -rf /var/log/varnish


fxTitle "Removing the working dir..."
rm -rf /var/lib/varnish


fxTitle "Removing the service customizations..."
## varnish.service.d/: 30-webstackup.conf by install.sh, 95_<app>.conf by zzdeploy, plus any local override
rm -rf /etc/systemd/system/varnish*


fxTitle "Removing repository-related files..."
rm -rf /usr/share/keyrings/*varnish*
rm -rf /etc/apt/keyrings/*varnish*
rm -rf /etc/apt/trusted.gpg.d/*varnish*
rm -rf /etc/apt/sources.list.d/*varnish*
rm -rf /etc/apt/preferences.d/99varnish


fxTitle "Removing the Varnish integration with NGINX..."
## 04_global_ip_forwarding.conf stays: nginx/install.sh links it too, and Cloudflare needs it as well
if [ -L /etc/nginx/varnish.conf ]; then

  WSU_NGINX_VARNISH_CONF_TARGET=$(readlink /etc/nginx/varnish.conf)
  rm -f /etc/nginx/varnish.conf

  ## a site that still includes it would make the next NGINX restart fail
  if [ -n "$(command -v nginx)" ] && ! WSU_NGINX_TEST_OUTPUT=$(nginx -t 2>&1); then

    ln -s "${WSU_NGINX_VARNISH_CONF_TARGET}" /etc/nginx/varnish.conf
    fxWarning "##nginx -t## fails without /etc/nginx/varnish.conf: link restored"
    echo "${WSU_NGINX_TEST_OUTPUT}"
  fi

else

  fxInfo "Not linked, skipping 🦘"
fi


fxTitle "Reloading service list..."
systemctl daemon-reload
## a unit that failed is still listed after its unit file is gone: scripts checking for "varnish" would still find it
systemctl reset-failed 'varnish*' > /dev/null 2>&1


if [ -n "$(command -v nginx)" ]; then

  fxTitle "Path to clean manually"
  fxInfo "NGINX config still proxying to Varnish"
  nginx -T 2>/dev/null | awk '/^# configuration file /{ FILE=$4; sub(/:$/, "", FILE) } /varnish\.conf|:6081/{ print FILE }' | sort -u
fi


fxEndFooter
