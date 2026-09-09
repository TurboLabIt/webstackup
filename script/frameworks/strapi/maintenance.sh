#!/usr/bin/env bash
## Strapi maintenance page activator by WEBSTACKUP
#
## The Strapi app is fully reverse-proxied, so maintenance mode is a pure-Nginx affair:
## the flag file lives in the webroot ("${WEBROOT_DIR}wsu-maintenance") and Nginx returns a 503
## before the request ever reaches the Node server, which needs to know nothing about it.
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=strapi` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/maintenance.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/maintenance.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

source "${WEBSTACKUP_SCRIPT_DIR}nginx/maintenance.sh"
