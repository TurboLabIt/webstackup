#!/usr/bin/env bash

# Variables
# ---------
# WSU_MAP_REPO_CLONE=yes|no
# WSU_MAP_NAME="My Amazing Shop On-Line"
# WSU_MAP_DOMAIN=my-shop.com
# WSU_MAP_APP_NAME=my-shop
# WSU_MAP_DEPLOY_TO_PATH=/var/www/$WSU_MAP_APP_NAME
WSU_MAP_AVAILABLE_FRAMEWORKS=("none" "symfony" "wordpress" "magento" "pimcore")
# WSU_MAP_FRAMEWORK=one of these ☝🏻☝🏻☝🏻☝🏻
# WSU_MAP_NEED_APACHE_HTTPD=yes|no
# WSU_MAP_PHP_VERSION=8.2
# WSU_MAP_PRE_EXEC_PAUSE_SEC=
# WSU_MAP_NEW_DATABASE=yes
# WSU_MAP_NEW_DATABASE_USER=usr_${WSU_MAP_APP_NAME}
# WSU_MAP_NEW_DATABASE_NAME=${WSU_MAP_APP_NAME}
# WSU_MAP_NEW_DATABASE_HOST=localhost
# WSU_MAP_RUN_FRAMEWORK_INSTALLER=yes
# WSU_MAP_ACTIVATE_SITE=yes

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "🐫 my-app-template"
rootCheck


fxTitle "✨ Webstackup check...."
WSU_MAP_ORIGIN=/usr/local/turbolab.it/webstackup/my-app-template/
if [ ! -d "${WSU_MAP_ORIGIN}" ]; then
  fxCatastrophicError "Webstackup not detected! Please install it locally: https://github.com/TurboLabIt/webstackup"
fi

source /usr/local/turbolab.it/webstackup/script/base.sh
fxOK "Webstackup is installed"

fxTitle "👤 Group and user check"
if ! getent group "www-data" &>/dev/null; then
  fxWarning "www-data group NOT found!"
  USER_FAILURE=1
fi

if ! id "webstackup" &>/dev/null; then
  fxWarning "webstackup user NOT found!"
  fxMessage "To create it now:"
  fxMessage "sudo useradd -G www-data webstackup --shell=/bin/false --create-home"
  USER_FAILURE=1
fi

if [ ! -z "${USER_FAILURE}" ]; then
 fxCatastrophicError "webstackup:www-data failure"
fi

fxOK "webstackup:www-data OK"


fxTitle "📂 Defining the temporary directory..."
WSU_MAP_TMP_DIR=/tmp/my-app-template/
rm -rf $WSU_MAP_TMP_DIR
fxOK "Temporary directory set to ##$WSU_MAP_TMP_DIR##"


fxTitle "🐑 Clone a Git repository"
while [ -z "$WSU_MAP_REPO_CLONE" ]; do

  echo "🤖 Start the clone repo wizard? Hit Enter for 'yes'"
  read -p ">> " -n 1 -r  < /dev/tty
  if [[ ! "$REPLY" =~ ^[Nn0]$ ]]; then
    WSU_MAP_REPO_CLONE=yes
  else
    WSU_MAP_REPO_CLONE=no
  fi

done

if [ "${WSU_MAP_REPO_CLONE}" = "yes" ] || [ "${WSU_MAP_REPO_CLONE}" = "1" ]; then

  # https://github.com/TurboLabIt/webstackup/blob/master/script/filesystem/git-clone.sh
  GIT_CLONE_TARGET_FOLDER=${WSU_MAP_TMP_DIR}
  GIT_CLONE_SKIP_DEPLOY=1
  source "${WEBSTACKUP_SCRIPT_DIR}filesystem/git-clone.sh"

else

  fxWarning "Please note that this is not standard procedure! The shell env will be set via the 'env' file"
fi


fxTitle "📛 Enter the name of the project"
fxInfo "For example: \"TurboLab.it\" or \"My Amazing Shop\" - YES, you can use spaces here!"
while [ -z "$WSU_MAP_NAME" ]; do

  echo "🤖 Provide the name of the project"
  read -p ">> " WSU_MAP_NAME  < /dev/tty

done

fxOK "OK, working on ##$WSU_MAP_NAME##"


## auto-generating a candidate APP_NAME
WSU_MAP_APP_NAME_DEFAULT=$(echo "$WSU_MAP_NAME" | tr '[:upper:]' '[:lower:]')
WSU_MAP_APP_NAME_DEFAULT=${WSU_MAP_APP_NAME_DEFAULT// /-}


fxTitle "🌎 Enter the domain"
fxInfo "For example: \"turbolab.it\" or \"www.turbolab.it\" or \"my-shop.com\""
fxWarning "Please use the PRODUCTION domain"
WSU_MAP_DOMAIN_DEFAULT=${WSU_MAP_APP_NAME_DEFAULT}.com
while [ -z "$WSU_MAP_DOMAIN" ]; do

  echo "🤖 Provide the domain or hit Enter for ##${WSU_MAP_DOMAIN_DEFAULT}##"
  read -p ">> " WSU_MAP_DOMAIN  < /dev/tty
  if [ -z "$WSU_MAP_DOMAIN" ]; then
    WSU_MAP_DOMAIN=$WSU_MAP_DOMAIN_DEFAULT
  fi

done

fxOK "Acknowledged, domain is ##$WSU_MAP_DOMAIN##"


fxTitle "🖥️ Choose the APP_NAME"
fxInfo "For example: \"turboLab_it\" or \"my-amazing-shop\""
fxWarning "Lowercase letters [a-z] and numbers [0-9] only!"
while [ -z "$WSU_MAP_APP_NAME" ]; do

  echo "🤖 Provide the APP_NAME or hit Enter for ##${WSU_MAP_APP_NAME_DEFAULT}##"
  read -p ">> " WSU_MAP_APP_NAME  < /dev/tty
  if [ -z "$WSU_MAP_APP_NAME" ]; then
    WSU_MAP_APP_NAME=$WSU_MAP_APP_NAME_DEFAULT
  fi

done

WSU_MAP_APP_NAME=$(echo "$WSU_MAP_APP_NAME" | tr '[:upper:]' '[:lower:]')
WSU_MAP_APP_NAME=${WSU_MAP_APP_NAME// /-}

fxOK "Got it, APP_NAME is ##$WSU_MAP_APP_NAME##"


fxTitle "📂 Choose the root path"
WSU_MAP_DEPLOY_TO_PATH_DEFAULT=/var/www/${WSU_MAP_APP_NAME}
while [ -z "$WSU_MAP_DEPLOY_TO_PATH" ]; do

  echo "🤖 Provide the path (use TAB!) or hit Enter for ##${WSU_MAP_DEPLOY_TO_PATH_DEFAULT}##"
  fxWarning "This should be the PRODUCTION path!"
  fxWarning "If you need a different path for dev, provide the PRODUCTION path anyway, "
  fxWarning "and then move the directory in dev manually"
  read -ep ">> " WSU_MAP_DEPLOY_TO_PATH  < /dev/tty
  if [ -z "$WSU_MAP_DEPLOY_TO_PATH" ]; then
    WSU_MAP_DEPLOY_TO_PATH=$WSU_MAP_DEPLOY_TO_PATH_DEFAULT
  fi

done

WSU_MAP_DEPLOY_TO_PATH=${WSU_MAP_DEPLOY_TO_PATH%*/}/
fxOK "Aye, aye! The app root path is ##$WSU_MAP_DEPLOY_TO_PATH##"


fxTitle "🔢 Enter the PHP version"
fxInfo "For example: \"7.4\" or \"8.2\""
while [ -z "$WSU_MAP_PHP_VERSION" ]; do

  WSU_MAP_DEFAULT_PHP_VERSION=8.2
  echo "🤖 Provide the PHP version to use or hit Enter for ##${WSU_MAP_DEFAULT_PHP_VERSION}##"
  read -p ">> " WSU_MAP_PHP_VERSION  < /dev/tty

  if [ -z "$WSU_MAP_PHP_VERSION" ]; then
    WSU_MAP_PHP_VERSION=${WSU_MAP_DEFAULT_PHP_VERSION}
  fi

done

fxOK "Sounds good, the project will use PHP ##$WSU_MAP_PHP_VERSION##"


fxTitle "🪶 Do you need Apache HTTP Server?"
if [ -z "${WSU_MAP_NEED_APACHE_HTTPD}" ]; then

  echo "🤖 Keep the Apache HTTPD Server config files? Hit Enter for 'yes'"
  read -p ">> " -n 1 -r  < /dev/tty
  if [[ ! "$REPLY" =~ ^[Nn0]$ ]]; then
    WSU_MAP_NEED_APACHE_HTTPD=yes
  else
    WSU_MAP_NEED_APACHE_HTTPD=no
  fi

fi

if [ "${WSU_MAP_NEED_APACHE_HTTPD}" = "yes" ] || [ "${WSU_MAP_NEED_APACHE_HTTPD}" = "1" ]; then

  WSU_MAP_NEED_APACHE_HTTPD=1
  fxOK "You're th boss! I'll keep them!"

else

  WSU_MAP_NEED_APACHE_HTTPD=0
  fxOK "Good choice, I'll crush them!"
fi


fxTitle "🦹 Choose the framework"
if [ -z "$WSU_MAP_FRAMEWORK" ]; then

  PS3="🤖 Choose your framework: #"
  select WSU_MAP_FRAMEWORK in "${WSU_MAP_AVAILABLE_FRAMEWORKS[@]}"; do
   break
  done
fi

if [ "${WSU_MAP_FRAMEWORK}" = "none" ] || [ "${WSU_MAP_FRAMEWORK}" = "symfony" ]; then
  fxOK "Outstanding, you're gonna build great things 🥳! Working with ##$WSU_MAP_FRAMEWORK##"
else
  fxOK "Whatever suits you.. Working with ##$WSU_MAP_FRAMEWORK##"
fi

WSU_MAP_UNCHOSEN_FRAMEWORKS=("${WSU_MAP_AVAILABLE_FRAMEWORKS[@]}")
for i in "${!WSU_MAP_UNCHOSEN_FRAMEWORKS[@]}"; do

  if [[ ${WSU_MAP_UNCHOSEN_FRAMEWORKS[i]} = $WSU_MAP_FRAMEWORK ]]; then
    unset 'WSU_MAP_UNCHOSEN_FRAMEWORKS[i]'
  fi

done

echo ""
echo "I'm gonna remove every file related to ##${WSU_MAP_UNCHOSEN_FRAMEWORKS[@]}##"


#### HERE WE GO ####

fxTitle "🚀 I'm 'bout to rock the show..."
fxMessage "Name:      ##$WSU_MAP_NAME##"
fxMessage "Domain:    ##$WSU_MAP_DOMAIN##"
fxMessage "App Name:  ##$WSU_MAP_APP_NAME##"
fxMessage "Path:      ##$WSU_MAP_DEPLOY_TO_PATH##"
fxMessage "PHP:       ##$WSU_MAP_PHP_VERSION##"
fxMessage "Apache:    ##$WSU_MAP_NEED_APACHE_HTTPD##"
fxMessage "Framework: ##$WSU_MAP_FRAMEWORK##"
fxCountdown ${WSU_MAP_PRE_EXEC_PAUSE_SEC}
echo ""


fxTitle "📂 Copying the template data to the temporary directory..."
rsync -a --exclude='/env' ${WSU_MAP_ORIGIN} "${WSU_MAP_TMP_DIR}"

## log directory
mkdir -p ${WSU_MAP_TMP_DIR}var/log

## removing this script
rm -f ${WSU_MAP_TMP_DIR}setup*.sh

fxTitle "💱 Replacing placeholder with project values..."
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "/var/www/my-app" "${WSU_MAP_DEPLOY_TO_PATH%*/}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "my-app.com" "${WSU_MAP_DOMAIN}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "my-app-php-version" "${WSU_MAP_PHP_VERSION}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "my-app-framework" "${WSU_MAP_FRAMEWORK}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "my-app" "${WSU_MAP_APP_NAME}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "My App Name" "${WSU_MAP_NAME}"

## oops..
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "webstackup/blob/master/${WSU_MAP_APP_NAME}" "webstackup/blob/master/my-app"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "www.www." ''

## the current redirect map name could be wsuRedirectToMap_something-something => wsuRedirectToMapSomethingsomething
WSU_MAP_REDIRECT_MAP_FROM_NAME=wsuRedirectToMap_${WSU_MAP_APP_NAME}
WSU_MAP_REDIRECT_MAP_TO_NAME=wsuRedirectToMap$(fxAlphanumOnly ${WSU_MAP_APP_NAME^})
echo "${WSU_MAP_REDIRECT_MAP_TO_NAME}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "${WSU_MAP_REDIRECT_MAP_FROM_NAME}" "${WSU_MAP_REDIRECT_MAP_TO_NAME}"

fxTitle "👓 Managing the .gitignore..."
if [ ! -f "${WSU_MAP_TMP_DIR}.gitignore" ]; then
  curl -Lo "${WSU_MAP_TMP_DIR}.gitignore" https://raw.githubusercontent.com/TurboLabIt/webdev-gitignore/master/.gitignore
else
  fxInfo "A .gitignore already exists, skipping"
fi


fxTitle "🌳 Dealing with the env file"
if [ ! -d "${WSU_MAP_TMP_DIR}.git" ] && [ ! -f "${WSU_MAP_TMP_DIR}env" ]; then
  cp ${WSU_MAP_ORIGIN}env ${WSU_MAP_TMP_DIR}env
else
  fxOK "Good! Either a .git folder or an 'env' file exists, skipping"
fi


fxTitle "🪶 Dealing with Apache HTTP Server config files..."
if [ "${WSU_MAP_NEED_APACHE_HTTPD}" != "1" ]; then

  rm -f ${WSU_MAP_TMP_DIR}scripts/*apache-httpd* \
    ${WSU_MAP_TMP_DIR}config/custom/*apache-httpd* \
    ${WSU_MAP_TMP_DIR}config/custom/dev/*apache-httpd* ${WSU_MAP_TMP_DIR}config/custom/staging/*apache-httpd* ${WSU_MAP_TMP_DIR}config/custom/prod/*apache-httpd*

else

  fxOK "Files kept"
fi


fxTitle "🦹 Applying customization for ##${WSU_MAP_FRAMEWORK}## framework..."
for WSU_MAP_UNCHOSEN_FRAMEWORK in "${WSU_MAP_UNCHOSEN_FRAMEWORKS[@]}"; do
  rm -f \
    ${WSU_MAP_TMP_DIR}scripts/*${WSU_MAP_UNCHOSEN_FRAMEWORK}* \
    ${WSU_MAP_TMP_DIR}config/custom/*${WSU_MAP_UNCHOSEN_FRAMEWORK}* \
    ${WSU_MAP_TMP_DIR}config/custom/dev/*${WSU_MAP_UNCHOSEN_FRAMEWORK}* ${WSU_MAP_TMP_DIR}config/custom/staging/*${WSU_MAP_UNCHOSEN_FRAMEWORK}* ${WSU_MAP_TMP_DIR}config/custom/prod/*${WSU_MAP_UNCHOSEN_FRAMEWORK}*
done

mv ${WSU_MAP_TMP_DIR}config/custom/nginx-${WSU_MAP_FRAMEWORK}.conf ${WSU_MAP_TMP_DIR}config/custom/nginx.conf


if [ "${WSU_MAP_FRAMEWORK}" = "magento" ]; then

  rm -rf ${WSU_MAP_TMP_DIR}public
  rm -rf ${WSU_MAP_TMP_DIR}var
  mkdir ${WSU_MAP_TMP_DIR}shop

  fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR}scripts '${PROJECT_DIR}var' '${MAGENTO_DIR}var'
  fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR}config/custom "${WSU_MAP_DEPLOY_TO_PATH}var/" "${WSU_MAP_DEPLOY_TO_PATH}shop/var/"
  fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR}config/custom "dev0/${WSU_MAP_APP_NAME}/var/" "dev0/${WSU_MAP_APP_NAME}/shop/var/"

  #rm -f ${WSU_MAP_TMP_DIR}config/custom/*zzmysqldump* \
    #${WSU_MAP_TMP_DIR}config/custom/dev/*zzmysqldump* ${WSU_MAP_TMP_DIR}config/custom/staging/*zzmysqldump* ${WSU_MAP_TMP_DIR}config/custom/prod/*zzmysqldump*
fi


if [ "${WSU_MAP_FRAMEWORK}" != "none" ] && [ "${WSU_MAP_FRAMEWORK}" != "symfony" ]; then
  rm -f ${WSU_MAP_TMP_DIR}scripts/*phpbb*
fi


fxTitle "🚚 Moving the built directory to ##${WSU_MAP_DEPLOY_TO_PATH}##..."
mkdir -p "${WSU_MAP_DEPLOY_TO_PATH}"
rsync -a ${WSU_MAP_TMP_DIR} "${WSU_MAP_DEPLOY_TO_PATH}"
rm -rf ${WSU_MAP_TMP_DIR}


fxTitle "🗃 Do you need a database?"
while [ -z "$WSU_MAP_NEW_DATABASE" ]; do

  echo "🤖 Start the database+credentials wizard? Hit Enter for 'yes'"
  read -p ">> " -n 1 -r  < /dev/tty
  if [[ ! "$REPLY" =~ ^[Nn0]$ ]]; then
    WSU_MAP_NEW_DATABASE=yes
  else
    WSU_MAP_NEW_DATABASE=no
  fi

done

if [ "${WSU_MAP_NEW_DATABASE}" = "yes" ] || [ "${WSU_MAP_NEW_DATABASE}" = "1" ]; then

  NEW_MYSQL_PASSWORD=auto
  bash "${WEBSTACKUP_SCRIPT_DIR}mysql/new.sh" "${WSU_MAP_APP_NAME}" "${WSU_MAP_NEW_DATABASE_USER}" "%" "" "$WSU_MAP_NEW_DATABASE_HOST" "${WSU_MAP_NEW_DATABASE_NAME}"

else

  fxOK "One less thing to backup, right?"
fi


fxTitle "🧙‍ Do you want to run your framework install script?"
while [ -z "$WSU_MAP_RUN_FRAMEWORK_INSTALLER" ]; do

  echo "🤖 Run ${WSU_MAP_FRAMEWORK}-install.sh? Hit Enter for 'yes'"
  read -p ">> " -n 1 -r  < /dev/tty
  if [[ ! "$REPLY" =~ ^[Nn0]$ ]]; then
    WSU_MAP_RUN_FRAMEWORK_INSTALLER=yes
  else
    WSU_MAP_RUN_FRAMEWORK_INSTALLER=no
  fi

done


fxSetWebPermissions "$(logname)" "${WSU_MAP_DEPLOY_TO_PATH}"


if [ "${WSU_MAP_RUN_FRAMEWORK_INSTALLER}" != "yes" ] && [ "${WSU_MAP_RUN_FRAMEWORK_INSTALLER}" != "1" ]; then

  fxOK "Well, well... Good luck setting up that thing on your own!"

elif [ ! -f "${WSU_MAP_DEPLOY_TO_PATH}scripts/${WSU_MAP_FRAMEWORK}-install.sh" ]; then

  fxWarning "Sorry, I've not built ##${WSU_MAP_FRAMEWORK}-install.sh## just yet. Ping me NOW about it please!"

else

  if [ "${WSU_MAP_FRAMEWORK}" != "symfony" ]; then
    nano "${WSU_MAP_DEPLOY_TO_PATH}scripts/${WSU_MAP_FRAMEWORK}-install.sh"
  fi

  bash "${WSU_MAP_DEPLOY_TO_PATH}scripts/${WSU_MAP_FRAMEWORK}-install.sh"
fi


fxTitle "🔗 Activate your website"
while [ -z "$WSU_MAP_ACTIVATE_SITE" ]; do

  echo "🤖 Link your dev/nginx.conf in Nginx? Hit Enter for 'yes'"
  read -p ">> " -n 1 -r  < /dev/tty
  if [[ ! "$REPLY" =~ ^[Nn0]$ ]]; then
    WSU_MAP_ACTIVATE_SITE=yes
  else
    WSU_MAP_ACTIVATE_SITE=no
  fi

done


if [ "${WSU_MAP_ACTIVATE_SITE}" != "yes" ] && [ "${WSU_MAP_ACTIVATE_SITE}" != "1" ]; then

  fxOK "Got it, you're on your own now"

else

  DIR_ABOVE_PATH=$(dirname "${WSU_MAP_DEPLOY_TO_PATH}")
  DEVELOPER_NAME=$(basename "${DIR_ABOVE_PATH}")

  fxInfo "dev name (inferred from path): ##${DEVELOPER_NAME}##"

  find "${WSU_MAP_DEPLOY_TO_PATH}config/custom/dev" -type f -exec sed -i "s/dev0/${DEVELOPER_NAME}/g" {} \;
  mv "${WSU_MAP_DEPLOY_TO_PATH}config/custom/dev/nginx-dev0.conf" "${WSU_MAP_DEPLOY_TO_PATH}config/custom/dev/nginx-${DEVELOPER_NAME}.conf"
  nano "${WSU_MAP_DEPLOY_TO_PATH}config/custom/dev/nginx-${DEVELOPER_NAME}.conf"

  ln -s "${WSU_MAP_DEPLOY_TO_PATH}config/custom/dev/nginx-${DEVELOPER_NAME}.conf" /etc/nginx/conf.d/${WSU_MAP_APP_NAME}_${DEVELOPER_NAME}.conf
  bash ${WEBSTACKUP_INSTALL_DIR_PARENT}zzalias/zzws.sh

  ls -la /etc/nginx/conf.d/ | grep ${WSU_MAP_APP_NAME}

fi


fxEndFooter
