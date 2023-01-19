#!/bin/bash
clear

export WSU_MAP_REPO_CLONE=yes
export GIT_CLONE_RUN_AS=$(logname)
export GIT_CLONE_REPO_URL=git@github.com:TurboLabIt/null.git
export GIT_CLONE_BRANCH=dev
export WSU_MAP_NAME="Webstackup MAP test"
export WSU_MAP_DOMAIN=webstackup-test.com
export WSU_MAP_APP_NAME=wsu-test
export WSU_MAP_DEPLOY_TO_PATH=/var/www/$WSU_MAP_APP_NAME
export WSU_MAP_AVAILABLE_FRAMEWORKS=("none" "symfony" "wordpress" "magento" "pimcore")
export WSU_MAP_FRAMEWORK=pimcore
export WSU_MAP_NEED_APACHE_HTTPD=no
export WSU_MAP_PHP_VERSION=8.2
export WSU_MAP_NEW_DATABASE=yes
export WSU_MAP_NEW_DATABASE_USER=usr_${WSU_MAP_APP_NAME}
export WSU_MAP_NEW_DATABASE_NAME=${WSU_MAP_APP_NAME}
export WSU_MAP_RUN_FRAMEWORK_INSTALLER=yes


sudo -u root -H -E bash "/usr/local/turbolab.it/webstackup/my-app-template/setup_run.sh"
