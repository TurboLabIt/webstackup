#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/strapi-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

## Leave it empty to get the latest Strapi 5 (create-strapi@latest)
#STRAPI_VERSION=5.52.3
STRAPI_VERSION=

## Leave it empty for the official default project (TypeScript or JavaScript, with or without the example data: you'll be asked).
## Anything accepted by `create-strapi --template` works: https://docs.strapi.io/cms/templates
#STRAPI_TEMPLATE=website
STRAPI_TEMPLATE=

## Public URL of this environment (https://...), stored as PUBLIC_URL in .env: reset-password links, absolute media URLs, ...
## Leave it empty if you don't know it yet: you can set it in .env later
STRAPI_PUBLIC_URL="${SITE_URL}"

## Admin panel path: "/admin" becomes "/${STRAPI_ADMIN_NEW_SLUG}" (security by obscurity, as for WordPress). Leave it empty to keep /admin
STRAPI_ADMIN_NEW_SLUG=my-app$(date +"%Y")

## First administrator, created by the installer (the password is generated and printed at the end). Leave the email empty to skip
STRAPI_ADMIN_FIRSTNAME="$(logname)"
STRAPI_ADMIN_LASTNAME=
STRAPI_ADMIN_EMAIL=admin@my-app.com

## Database: created by the my-app-template wizard. Without it, Strapi falls back to SQLite (dev only!)
if [ -f "/etc/turbolab.it/mysql-${APP_NAME}.conf" ]; then
  source "/etc/turbolab.it/mysql-${APP_NAME}.conf"
fi

source ${WEBSTACKUP_SCRIPT_DIR}node.js/strapi_new.sh

source "${SCRIPT_DIR}/script_end.sh"
