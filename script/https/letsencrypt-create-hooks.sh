#!/usr/bin/env bash
## Let's Encrypt post-renewal hook
# https://certbot.eff.org/docs/using.html?highlight=hook#renewing-certificates
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/letsencrypt-create-hooks.sh?$(date +%s) | sudo bash
#
SCRIPT_NAME=letsencrypt-create-hooks

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🪝 LET'S ENCRYPT CREATE HOOKS"


if [ -d /etc/letsencrypt/renewal-hooks/deploy ]; then

  fxTitle "🔃 Deploying Let's Encrypt post-renewal hook..."
  sudo curl -Lo /etc/letsencrypt/renewal-hooks/deploy/nginx_restart https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/nginx/restart.sh
  sudo chown root:root /etc/letsencrypt/renewal-hooks/deploy/nginx_restart
  sudo chmod u=rwx,go=rx /etc/letsencrypt/renewal-hooks/deploy/nginx_restart

  fxTitle "✅ Script deployed"
  ls -latrh /etc/letsencrypt/renewal-hooks/deploy

  fxTitle "☀ Renewing certificates..."
  sudo certbot renew --force-renewal --no-random-sleep-on-renew
  
else

  fxInfo "##/etc/letsencrypt/renewal-hooks/deploy## doesn't exist"
  fxInfo "Let's Encrypt post-renewal hook skipped"
fi

fxEndFooter
