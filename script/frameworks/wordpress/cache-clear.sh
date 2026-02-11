#!/usr/bin/env bash
## Standard WordPress cache-clearing routine by WEBSTACKUP
#
# How to:
#
# 1. set `PROJECT_FRAMEWORK=wordpress` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/cache-clear.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/cache-clear.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzcache` directly

fxHeader "🧹 WordPress cache-clear"

showPHPVer

if [ -z "${PROJECT_DIR}" ] || [ ! -d "${PROJECT_DIR}" ]; then
  fxCatastrophicError "📁 PROJECT_DIR not set"
fi

if [ "$1" = "fast" ]; then
  FAST_CACHE_CLEAR=1
fi


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then

  fxTitle "⚙️ Stopping services..."
  sudo nginx -t && sudo service nginx stop
  sudo service ${PHP_FPM} restart
fi


fxTitle "👮 Setting permissions on WordPress dir..."
sudo chown -R webstackup:www-data "${WEBROOT_DIR}" -R
sudo chmod ugo= "${WEBROOT_DIR}" -R
sudo chmod ug=rwX,o= "${WEBROOT_DIR}" -R
sudo chmod g+s "${WEBROOT_DIR}"

sudo chown www-data "${WEBROOT_DIR}wp-content" -R


## build
if [ -z "${FAST_CACHE_CLEAR}" ] && [ -f "${SCRIPT_DIR}build.sh" ]; then
  bash "${SCRIPT_DIR}build.sh"
fi


## https://www.wpfastestcache.com/features/wp-cli-commands/
wsuWordPress fastest-cache clear all and minified


if [ -z "${FAST_CACHE_CLEAR}" ] && [ "${APP_ENV}" != "dev" ]; then

  fxTitle "⚙️ Restarting services..."
  sudo service ${PHP_FPM} restart
  sudo nginx -t && sudo service nginx start
fi


if [ "$APP_ENV" = "dev" ]; then

  fxTitle "chown dev..."
  sudo chown $(logname):www-data "${PROJECT_DIR}" -R
  sudo chmod ugo= "${PROJECT_DIR}" -R
  sudo chmod ugo=rwx "${PROJECT_DIR}" -R
fi


fxTitle "Final status..."
ls -la "${PROJECT_DIR}"
