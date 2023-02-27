#!/bin/bash
clear

export WSU_MAP_REPO_CLONE=no
export GIT_CLONE_RUN_AS=$(logname)
export GIT_CLONE_REPO_URL=git@github.com:TurboLabIt/null.git
export GIT_CLONE_BRANCH=dev

export WSU_MAP_NAME="My test app $(date +%s)"
export WSU_MAP_APP_NAME=wsu-map-test-$(date +%s)
export WSU_MAP_DOMAIN=${WSU_MAP_APP_NAME}.io
export WSU_MAP_DEPLOY_TO_PATH=/var/www/zane/$WSU_MAP_APP_NAME

export WSU_MAP_FRAMEWORK=magento
export WSU_MAP_RUN_FRAMEWORK_INSTALLER=yes

export WSU_MAP_NEED_APACHE_HTTPD=no
export WSU_MAP_PHP_VERSION=8.2

export WSU_MAP_PRE_EXEC_PAUSE_SEC=2

export WSU_MAP_NEW_DATABASE=yes
export WSU_MAP_NEW_DATABASE_USER=usr_${WSU_MAP_APP_NAME}
export WSU_MAP_NEW_DATABASE_NAME=${WSU_MAP_APP_NAME}

export WSU_MAP_ACTIVATE_SITE=yes

sudo -u root -H -E bash "/usr/local/turbolab.it/webstackup/my-app-template/setup_run.sh"
