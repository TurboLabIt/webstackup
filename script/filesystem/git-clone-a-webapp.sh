#!/usr/bin/env bash
### GUIDED PROJECT CLONING AND STARTUP BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/filesystem/git_cloner.sh
echo ""

source "/usr/local/turbolab.it/webstackup/script/base.sh"
printHeader "🚀 Git clone and setup a remote web app"
rootCheck


if [ -z "$(command -v git)" ]; then

  printTitle "📦 Installing prerequisites..."
  apt update && apt install git -y
  
fi


printTitle "🔑 Please authorize this key to access the target repository"
cat /home/webstackup/.ssh/id_rsa.pub


printTitle "🌎 Repository URL"
while [ -z "$NEWSITE_REPO_URL" ]
do
  read -p "🤖 Provide the URL to clone (e.g.: git@github.com:TurboLabIt/webstackup.git): " NEWSITE_REPO_URL  < /dev/tty
  
  sudo -u webstackup -H git ls-remote ${NEWSITE_REPO_URL} -q
  if [ $? != 0 ]; then
  
    echo ""
	NEWSITE_REPO_URL=
	
  fi
  
done

printMessage "ℹ $NEWSITE_REPO_URL"


printTitle "📁 Repository directory"
while [ -z "$NEWSITE_FOLDER_NAME" ]
do
  echo "ℹ The application will be cloned into /var/www/<my-app>"
  read -p "🤖 Provide the name of the directory to clone into (e.g.: my-app): " NEWSITE_FOLDER_NAME  < /dev/tty
  
  LOCAL_CLONE_FULLPATH=/var/www/${NEWSITE_FOLDER_NAME}
  if [ -d ${LOCAL_CLONE_FULLPATH} ] || [ -d ${LOCAL_CLONE_FULLPATH} ]; then
  
    echo "⛔ Can't do, ${LOCAL_CLONE_FULLPATH} exists: "
	ls -la ${LOCAL_CLONE_FULLPATH}
	
  fi
  
done

# remove the trailing "/"
NEWSITE_FOLDER_NAME=${NEWSITE_FOLDER_NAME%*/}

printMessage "ℹ $NEWSITE_FOLDER_NAME"


printTitle "🌿 Choose a branch"
sudo -u webstackup -H git ls-remote $NEWSITE_REPO_URL

while [ -z "$NEWSITE_BRANCH" ]
do
  read -p "🤖 Provide the name of the branch  (e.g.: dev): " NEWSITE_BRANCH  < /dev/tty
done

printMessage "ℹ $NEWSITE_BRANCH"


printTitle "🏭 Cloning ${NEWSITE_REPO_URL} into ${NEWSITE_FOLDER_NAME}..."
sudo -u webstackup -H git clone ${NEWSITE_REPO_URL} /home/webstackup/clone-temp-${NEWSITE_FOLDER_NAME}
sudo -u webstackup -H git -C /home/webstackup/clone-temp-${NEWSITE_FOLDER_NAME} switch ${NEWSITE_BRANCH}
mv /home/webstackup/clone-temp-${NEWSITE_FOLDER_NAME} ${LOCAL_CLONE_FULLPATH}
git -C ${LOCAL_CLONE_FULLPATH} status
git -C ${LOCAL_CLONE_FULLPATH} branch

bash ${WEBSTACKUP_SCRIPT_DIR}filesystem/webpermission.sh ${LOCAL_CLONE_FULLPATH}

bash ${WEBSTACKUP_SCRIPT_DIR}mysql/new.sh


printTitle "🤠 Would you like to deploy?"
if [ -f ${LOCAL_CLONE_FULLPATH}/script/deploy.sh ]; then

  DEPLOY_SCRIPT=${LOCAL_CLONE_FULLPATH}/script/deploy.sh
  
elif [ -f ${LOCAL_CLONE_FULLPATH}/scripts/deploy.sh ]; then

  DEPLOY_SCRIPT=${LOCAL_CLONE_FULLPATH}/scripts/deploy.sh
  
elif [ -f ${LOCAL_CLONE_FULLPATH}/www/script/deploy.sh ]; then

  DEPLOY_SCRIPT=${LOCAL_CLONE_FULLPATH}/www/script/deploy.sh
  
elif [ -f ${LOCAL_CLONE_FULLPATH}/www/scripts/deploy.sh ]; then

  DEPLOY_SCRIPT=${LOCAL_CLONE_FULLPATH}/www/scripts/deploy.sh
  
else

  read -p "🤖 Provide the full path to the deploy script (e.g.: ${LOCAL_CLONE_FULLPATH}/utils/deploy.sh): " DEPLOY_SCRIPT  < /dev/tty
fi

if [ ! -z $DEPLOY_SCRIPT ]; then 

  bash ${DEPLOY_SCRIPT}
fi

printTheEnd
