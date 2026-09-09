## Standard Strapi script init by WEBSTACKUP.
# Sourced by https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/script_begin.sh

## my-app-template stamps NODE_PORT=1337 (Strapi's default, PORT in .env) into scripts/script_begin.sh: this is the fallback
## for projects that were not scaffolded (e.g. PROJECT_FRAMEWORK switched to strapi by hand). It must match $proxy_pass_target in config/custom/nginx.conf
if [ -z "${NODE_PORT}" ]; then
  NODE_PORT=1337
fi
