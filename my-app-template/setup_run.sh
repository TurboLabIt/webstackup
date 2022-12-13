#!/usr/bin/env bash

### MANAGED VARIABLES ###
#########################

# WSU_MAP_NAME="My Amazing Shop On-Line"
# WSU_MAP_DOMAIN=my-shop.com
# WSU_MAP_APP_NAME=my-shop
# WSU_MAP_DEPLOY_TO_PATH=/var/www/$WSU_MAP_APP_NAME
WSU_MAP_AVAILABLE_FRAMEWORKS=("none" "symfony" "wordpress" "magento" "pimcore")
# WSU_MAP_FRAMEWORK=one of these ☝🏻☝🏻☝🏻☝🏻
# WSU_MAP_NEED_APACHE_HTTPD=yes|no


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


WSU_MAP_ORIGIN=/usr/local/turbolab.it/webstackup/my-app-template/
if [ ! -d "${WSU_MAP_ORIGIN}" ]; then
  fxCatastrophicError "Webstackup not detected! Please install it locally: https://github.com/TurboLabIt/webstackup"
fi

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


fxTitle "📛 Enter the name of the project"
fxInfo "For example: \"TurboLab.it\" or \"My Amazing Shop\" - YES, you can use spaces here!"
while [ -z "$WSU_MAP_NAME" ]
do
  echo "🤖 Provide the name of of the project"
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
while [ -z "$WSU_MAP_DOMAIN" ]
do
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
fxWarning "You should really accept the default 😉"
while [ -z "$WSU_MAP_DEPLOY_TO_PATH" ]; do

  echo "🤖 Provide the path (use TAB!) or hit Enter for ##${WSU_MAP_DEPLOY_TO_PATH_DEFAULT}##"
  read -ep ">> " WSU_MAP_DEPLOY_TO_PATH  < /dev/tty
  if [ -z "$WSU_MAP_DEPLOY_TO_PATH" ]; then
    WSU_MAP_DEPLOY_TO_PATH=$WSU_MAP_DEPLOY_TO_PATH_DEFAULT
  fi

  if [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ] && [ -d "$(dirname "$WSU_MAP_DEPLOY_TO_PATH")" ]; then
    mkdir -p "$WSU_MAP_DEPLOY_TO_PATH"
  fi

  if [ ! -d "$WSU_MAP_DEPLOY_TO_PATH" ]; then
    fxWarning "Directory ##${WSU_MAP_DEPLOY_TO_PATH}## doesn't exist!" "proceed"
    WSU_MAP_DEPLOY_TO_PATH=
    echo ""
  fi

done

WSU_MAP_DEPLOY_TO_PATH=${WSU_MAP_DEPLOY_TO_PATH%*/}/
fxOK "Aye, aye! The app root path is ##$WSU_MAP_DEPLOY_TO_PATH##"


fxTitle "🪶 Do you need Apache HTTP Server?"
if [ -z "${WSU_MAP_NEED_APACHE_HTTPD}" ]; then

  PS3="🤖 Remove config files for Apache HTTPD Server? #"
  select WSU_MAP_NEED_APACHE_HTTPD in "yes" "no"; do
   break
  done
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
fxMessage "Apache:    ##${WSU_MAP_NEED_APACHE_HTTPD}##"
fxMessage "Framework: ##$WSU_MAP_FRAMEWORK##"
fxCountdown
echo ""


fxTitle "📂 Building the temporary directory..."
WSU_MAP_TMP_DIR=/tmp/my-app-template/
rm -rf $WSU_MAP_TMP_DIR
mkdir $WSU_MAP_TMP_DIR
cp -r ${WSU_MAP_ORIGIN} /tmp/

## log directory
mkdir -p ${WSU_MAP_TMP_DIR}var/log

## removing this script
rm -f ${WSU_MAP_TMP_DIR}setup*.sh

fxTitle "💱 Replacing placeholder with project values..."
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "/var/www/my-app" "${WSU_MAP_DEPLOY_TO_PATH%*/}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "my-app.com" "${WSU_MAP_DOMAIN}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "my-app-framework" "${WSU_MAP_FRAMEWORK}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "my-app" "${WSU_MAP_APP_NAME}"
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "My App Name" "${WSU_MAP_NAME}"

## oops..
fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR} "webstackup/blob/master/${WSU_MAP_APP_NAME}" "webstackup/blob/master/my-app"

fxTitle "👓 Acquiring gitignore..."
curl -Lo "${WSU_MAP_TMP_DIR}.gitignore" https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore?$(date +%s)


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
  rm -f ${WSU_MAP_TMP_DIR}scripts/*${WSU_MAP_UNCHOSEN_FRAMEWORK}*
done


if [ "${WSU_MAP_FRAMEWORK}" = "magento" ]; then

  rm -rf ${WSU_MAP_TMP_DIR}public
  mkdir ${WSU_MAP_TMP_DIR}shop

  fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR}scripts '${PROJECT_DIR}var' '${MAGENTO_DIR}var'
  fxReplaceContentInDirectory ${WSU_MAP_TMP_DIR}config/custom "${WSU_MAP_DEPLOY_TO_PATH}var" "${WSU_MAP_DEPLOY_TO_PATH}shop/var"

  rm -f ${WSU_MAP_TMP_DIR}config/custom/*zzmysqldump* \
    ${WSU_MAP_TMP_DIR}config/custom/dev/*zzmysqldump* ${WSU_MAP_TMP_DIR}config/custom/staging/*zzmysqldump* ${WSU_MAP_TMP_DIR}config/custom/prod/*zzmysqldump*

fi


if [ "${WSU_MAP_FRAMEWORK}" != "none" ] && [ "${WSU_MAP_FRAMEWORK}" != "symfony" ]; then
  rm -f ${WSU_MAP_TMP_DIR}scripts/*phpbb*
fi


ls -l ${WSU_MAP_TMP_DIR}scripts/

fxTitle "👮 Setting permissions..."
chown webstackup:www-data /tmp/my-app-template -R
chmod u=rwx,go=rX /tmp/my-app-template -R
chmod u=rwx,go=rx ${WSU_MAP_TMP_DIR}scripts/*.sh -R
chmod u=rwx,go=rwX ${WSU_MAP_TMP_DIR}var -R

fxTitle "🚚 Moving the built directory to ##${WSU_MAP_DEPLOY_TO_PATH}##..."
rsync -a ${WSU_MAP_TMP_DIR} "${WSU_MAP_DEPLOY_TO_PATH}"
rm -rf ${WSU_MAP_TMP_DIR}

fxEndFooter

