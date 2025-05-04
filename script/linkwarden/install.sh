#!/usr/bin/env bash
### AUTOMATIC LINKWARDEN INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/linkwarden/install.sh
#
# sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/linkwarden/install.sh | sudo bash

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi

if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 linkwarden installer"
rootCheck


fxTitle "Allow new registrations?"
if [ -z "${LINKWARDEN_ALLOW_REGISTRATIONS}" ]; then

  echo "🤖 Hit Y the first time, then N"
  read -p ">> " -n 1 -r  < /dev/tty
  if [[ ! "$REPLY" =~ ^[Nn0]$ ]]; then
    LINKWARDEN_ALLOW_REGISTRATIONS=1
  else
    LINKWARDEN_ALLOW_REGISTRATIONS=0
  fi
fi


fxTitle "Stopping the service..."
service linkwarden stop


fxTitle "Installing pre-requisites..."
apt update
apt install git postgresql postgresql-contrib -y


# https://github.com/TurboLabIt/webstackup/tree/master/script/account/generate-www-data.sh
curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/account/generate-www-data.sh | sudo bash


LINKWARDEN_INSTALL_DIR=/var/www/linkwarden/

fxTitle "Application check..."
if [ ! -d "${LINKWARDEN_INSTALL_DIR}" ]; then

  fxInfo "Directory not found. Cloning..."
  sudo -u webstackup -H git clone https://github.com/linkwarden/linkwarden.git "${LINKWARDEN_INSTALL_DIR}"
fi


function linkwardenSetWebPermissions()
{
  fxTitle "Setting permissions..."
  mkdir -p "${LINKWARDEN_INSTALL_DIR}apps/web/.next/cache"
  chown webstackup:www-data "${LINKWARDEN_INSTALL_DIR}" -R
  chmod ugo= "${LINKWARDEN_INSTALL_DIR}" -R
  chmod u=rwx,go=rX "${LINKWARDEN_INSTALL_DIR}" -R
  chmod g+w "${LINKWARDEN_INSTALL_DIR}apps/web/.next/cache" -R
}

linkwardenSetWebPermissions


fxTitle "Switching to ##${LINKWARDEN_INSTALL_DIR}##..."
cd "${LINKWARDEN_INSTALL_DIR}"
sudo -u webstackup -H git reset --hard
sudo -u webstackup -H git pull


fxTitle "Managing .env..."
if [ ! -f "${LINKWARDEN_INSTALL_DIR}.env" ]; then

  LINKWARDEN_DB_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c32)
  sudo -u postgres psql -c "CREATE USER linkwarden WITH PASSWORD '${LINKWARDEN_DB_PASSWORD}';"

  cp .env.sample .env
  sed -i "s/^NEXTAUTH_SECRET=.*/NEXTAUTH_SECRET=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c32)/" .env
  sed -i "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://linkwarden:${LINKWARDEN_DB_PASSWORD}@localhost:5432/linkwarden/|" .env

fi


## 📚 https://docs.linkwarden.app/self-hosting/environment-variables
if [ "${LINKWARDEN_ALLOW_REGISTRATIONS}" = 0 ]; then

  sed -i "s/^NEXT_PUBLIC_DISABLE_REGISTRATION=.*/NEXT_PUBLIC_DISABLE_REGISTRATION=true/" .env
  sed -i "s/^DISABLE_NEW_SSO_USERS=.*/DISABLE_NEW_SSO_USERS=true/" .env

else

  sed -i "s/^NEXT_PUBLIC_DISABLE_REGISTRATION=.*/NEXT_PUBLIC_DISABLE_REGISTRATION=/" .env
  sed -i "s/^DISABLE_NEW_SSO_USERS=.*/DISABLE_NEW_SSO_USERS=/" .env
fi


if [ -z $(command -v yarn) ]; then
  
  # https://github.com/TurboLabIt/webstackup/tree/master/script/node.js/install.sh
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/node.js/install.sh | sudo bash
fi


function linkwardenBuild()
{
  fxTitle "🧶 Yarn..."
  yarn
  yarn prisma:generate
  yarn web:build
  yarn prisma:deploy
  linkwardenSetWebPermissions
}

linkwardenBuild


fxTitle "Deploying the service unit file..."
LINKWARDEN_SERVICE_FILE=/etc/systemd/system/linkwarden.service
WSU_LINKWARDEN_SERVICE_FILE=/usr/local/turbolab.it/webstackup/script/linkwarden/service.txt
if [ -f "${WSU_LINKWARDEN_SERVICE_FILE}" ]; then

  fxLink "${WSU_LINKWARDEN_SERVICE_FILE}" "${LINKWARDEN_SERVICE_FILE}"

else

  curl -Lo "${LINKWARDEN_SERVICE_FILE}" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/linkwarden/service.txt
fi

systemctl daemon-reload
systemctl enable linkwarden
service linkwarden restart


fxEndFooter
