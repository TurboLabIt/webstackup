#!/usr/bin/env bash

## Let's Encrypt post-renewal hook
# https://certbot.eff.org/docs/using.html?highlight=hook#renewing-certificates
if [ ! -d "/etc/letsencrypt/renewal-hooks/deploy/" ]; then

  echo "Deploying Let's Encrypt post-renewal hook..."
  sudo curl -Lo /etc/letsencrypt/renewal-hooks/deploy/nginx_restart https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/nginx/restart.sh
  chown root:root /etc/letsencrypt/renewal-hooks/deploy/nginx_restart
  sudo chmod u=rwx,go=rx /etc/letsencrypt/renewal-hooks/deploy/nginx_restart
  sudo certbot renew --force-renewal
fi
