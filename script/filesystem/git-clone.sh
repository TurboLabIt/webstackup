#!/usr/bin/env bash
### GUIDED PROJECT CLONING BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/filesystem/git-clone.sh
#
# Variables
# ---------
# GIT_CLONE_RUN_AS
# GIT_CLONE_REPO_URL
# GIT_CLONE_TARGET_FOLDER
# GIT_CLONE_BRANCH


## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready


fxHeader "🐑 Git clone wizard"
rootCheck


fxTitle "👤 Provide the user to clone as"
fxInfo "This is the name of the Linux user account to sudo -u as"
while [ -z "$GIT_CLONE_RUN_AS" ]; do

  echo "🤖 Provide the username or just hit Enter for ##webstackup##"
  read -p ">> " GIT_CLONE_RUN_AS  < /dev/tty

  if [ -z "${GIT_CLONE_RUN_AS}" ]; then
    GIT_CLONE_RUN_AS=webstackup
  fi

  if ! id "${GIT_CLONE_RUN_AS}" &>/dev/null; then

    fxWarning "username NOT found!"
    GIT_CLONE_RUN_AS=
  fi

done

fxOK "OK, running as ##${GIT_CLONE_RUN_AS}##"


fxTitle "🔑 SSH key check"
if [ "${GIT_CLONE_RUN_AS}" = root ]; then
  GIT_CLONE_SSH_KEY=/root/.ssh/id_rsa.pub
else
  GIT_CLONE_SSH_KEY=/home/${GIT_CLONE_RUN_AS}/.ssh/id_rsa.pub
fi

fxInfo "Default SSH key found: ##${GIT_CLONE_SSH_KEY}##"
echo ""

if [ ! -f "${GIT_CLONE_SSH_KEY}" ]; then

  fxWarning "##${GIT_CLONE_SSH_KEY}## not found! Repository access may be denied"

else

  fxInfo "Your key should be authorized to access the repo you want to clone"
  fxMessage "$(cat ${GIT_CLONE_SSH_KEY})"
fi


fxTitle "🌎 Enter the repository URL"
fxInfo "For example: git@github.com:TurboLabIt/html-pages.git or git@bitbucket.org:turbolabit/html-pages.git"


function gitCloneGitCmd()
{
  if [ "$(whoami)" = "${GIT_CLONE_RUN_AS}" ]; then

    git "$@"
    GIT_CMD_RESULT=$?

  else

    sudo -u ${GIT_CLONE_RUN_AS} -H git "$@"
    GIT_CMD_RESULT=$?

  fi
}


while [ -z "$GIT_CLONE_REPO_URL" ]; do

  echo "🤖 Provide the URL of the repository"
  read -p ">> " GIT_CLONE_REPO_URL  < /dev/tty

  GIT_CLONE_REPO_URL=${GIT_CLONE_REPO_URL#git clone}

  if [ ! -z "${GIT_CLONE_REPO_URL}" ]; then

    gitCloneGitCmd ls-remote ${GIT_CLONE_REPO_URL} -q
    if [ "$GIT_CMD_RESULT" != 0 ]; then

      fxWarning "🛑 Repository access DENIED!"
      GIT_CLONE_REPO_URL=
    fi

  fi

done

fxOK "OK, origin set to ##$GIT_CLONE_REPO_URL##"


fxTitle "🌿 Choose a branch"
gitCloneGitCmd ls-remote $GIT_CLONE_REPO_URL

while [ -z "$GIT_CLONE_BRANCH" ]; do

  echo "🤖 Provide the name of the branch  (e.g.: master) or just hit Enter for ##dev##"
  read -p ">> " GIT_CLONE_BRANCH  < /dev/tty

  if [ -z "${GIT_CLONE_BRANCH}" ]; then
    GIT_CLONE_BRANCH=dev
  fi

done

fxOK "Good choice! ##${GIT_CLONE_BRANCH}## is my favourite branch too!"


fxTitle "📁 Repository directory"
fxInfo "For example: /var/www/some-dir"
while [ -z "$GIT_CLONE_TARGET_FOLDER" ]; do

  echo "🤖 Provide the full path (use TAB!) of the directory to clone into"
  read -ep ">> " GIT_CLONE_TARGET_FOLDER  < /dev/tty

done

mkdir -p "$GIT_CLONE_TARGET_FOLDER"
chmod ugo=rwx "$GIT_CLONE_TARGET_FOLDER"

# the path must end with one trailing "/"
GIT_CLONE_TARGET_FOLDER=${GIT_CLONE_TARGET_FOLDER%*/}/
fxOK "OK, cloning to ##${GIT_CLONE_TARGET_FOLDER}##"


#### HERE WE GO ####

fxTitle "🚀 Start to groove, bust the move..."
fxMessage "User:      ##$GIT_CLONE_RUN_AS##"
fxMessage "URL:       ##$GIT_CLONE_REPO_URL##"
fxMessage "Branch:    ##$GIT_CLONE_BRANCH##"
fxMessage "Path:      ##$GIT_CLONE_TARGET_FOLDER##"
fxCountdown
echo ""


fxTitle "🐑🐑 Cloning ${GIT_CLONE_REPO_URL} into ${GIT_CLONE_TARGET_FOLDER}..."
gitCloneGitCmd clone ${GIT_CLONE_REPO_URL} ${GIT_CLONE_TARGET_FOLDER}

fxTitle "😡 Setting safe.directory..."
gitCloneGitCmd config --global --add safe.directory "${GIT_CLONE_TARGET_FOLDER%*/}"
git config --global --add safe.directory "${GIT_CLONE_TARGET_FOLDER%*/}"

fxTitle "🌿 Switching branch..."
gitCloneGitCmd -C ${GIT_CLONE_TARGET_FOLDER} switch -c ${GIT_CLONE_BRANCH}

fxTitle "👮 Setting Git filemode to false..."
gitCloneGitCmd -C ${GIT_CLONE_TARGET_FOLDER} config core.fileMode false

fxTitle "📃 Directory status.."
gitCloneGitCmd -C ${GIT_CLONE_TARGET_FOLDER} status
gitCloneGitCmd -C ${GIT_CLONE_TARGET_FOLDER} branch
ls -la ${GIT_CLONE_TARGET_FOLDER}

fxEndFooter

