## Framework-initiated remote-dump and download

fxHeader "🗄️️ Remote database dump-and-download"


echo "🖥 REMOTE_SERVER:         ##${REMOTE_SERVER}##"
echo "📂 REMOTE_PROJECT_DIR:    ##${REMOTE_PROJECT_DIR}##"
echo "🌳 REMOTE_APP_ENV:        ##${REMOTE_APP_ENV}##"
echo "👤 REMOTE_SSH_USERNAME:   ##${REMOTE_SSH_USERNAME}"
echo "💨 DISABLE_SSH_TEST:      ##${DISABLE_SSH_TEST}##"


if [ -z "${REMOTE_SERVER}" ] || [ -z "${REMOTE_PROJECT_DIR}" ] || [ -z "${REMOTE_APP_ENV}" ]; then
   catastrophicError "db-download can't run with any of these variables undefined: REMOTE_SERVER, REMOTE_PROJECT_DIR, REMOTE_APP_ENV"
fi


fxTitle "👤@🖥 setup..."
if [ -z "${REMOTE_SSH_USERNAME}" ]; then
  USER_AT_HOST=${REMOTE_SERVER}
else
  USER_AT_HOST=${REMOTE_SSH_USERNAME}@${REMOTE_SERVER}
fi

fxInfo "OK, SSH is about to run as ##${USER_AT_HOST}##"


if [ "${DISABLE_SSH_TEST}" != 1 ] ; then

  fxSshTestAccess ${USER_AT_HOST}
  fxSshCheckRemoteDirectory ${USER_AT_HOST} ${REMOTE_PROJECT_DIR}
  
else
  
  fxTitle "🧪 Tesing remote host.."
  fxInfo "Test disabled, skipping"
fi


fxTitle "🔭 Running remote db-dump..."
ssh -t ${USER_AT_HOST} "bash ${REMOTE_PROJECT_DIR}scripts/db-dump.sh"


## create local $DB_DUMP_DIR
wsuMkDbDumpDir


fxTitle "⬇️ Downloading..."
rsync --archive --compress --partial --progress --verbose ${USER_AT_HOST}:${REMOTE_PROJECT_DIR}backup/db-dump/ ${DB_DUMP_DIR}
