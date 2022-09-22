#!/usr/bin/env bash
## Main deploy script.
#
# ⚠️ Don't run this script directly! Use `bash deploy.sh` instead.
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/deploy_run.sh

SCRIPT_NAME=deploy
source $(dirname $(readlink -f $0))/script_begin.sh
fxCatastrophicError "deploy_run.sh is not ready! Please customize it and remove this line when done"
## let's start!
# https://github.com/TurboLabIt/webstackup/blob/master/script/filesystem/deploy-begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}filesystem/deploy-begin.sh"

## required PHP extensions
fxTitle "Installing required PHP extensions..."
apt update && apt install php${PHP_VER}-bcmath php${PHP_VER}-ctype php${PHP_VER}-curl php${PHP_VER}-dom php${PHP_VER}-fileinfo php${PHP_VER}-gd php${PHP_VER}-iconv php${PHP_VER}-intl php${PHP_VER}-json php${PHP_VER}-xml php${PHP_VER}-mbstring php${PHP_VER}-mysql php${PHP_VER}-simplexml php${PHP_VER}-soap php${PHP_VER}-sockets php${PHP_VER}-xmlwriter php${PHP_VER}-xsl php${PHP_VER}-zip libxml2 openssl -y

## ... run your own pre-pull, pre-composer tasks ... ##

## pre-deploy Magento setup (remove if this is NOT a Magento-based app)
# https://github.com/TurboLabIt/webstackup/blob/master/script/frameworks/magento/pre-deploy.sh
fxTitle "📦 Setting up composer credentials..."
wsuComposer config --global http-basic.repo.magento.com myKey1 myKey2
source "${WEBSTACKUP_SCRIPT_DIR}frameworks/magento/pre-deploy.sh"

## common deploy tasks
# https://github.com/TurboLabIt/webstackup/blob/master/script/filesystem/deploy-common.sh
source "${WEBSTACKUP_SCRIPT_DIR}filesystem/deploy-common.sh"

## ... run your own post-pull, post-composer tasks ... ##

## finishing up
# https://github.com/TurboLabIt/webstackup/blob/master/script/filesystem/deploy-end.sh
source "${WEBSTACKUP_SCRIPT_DIR}filesystem/deploy-end.sh"

