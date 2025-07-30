fxHeader "🧹 phpBB cleaner"

MYSQL_CREDENTIALS_FILE=/etc/turbolab.it/mysql.conf
if [ ! -e "${MYSQL_CREDENTIALS_FILE}" ]; then
  fxCatastrophicError "Credentials file ${MYSQL_CREDENTIALS_FILE} not found!"
fi

source "${MYSQL_CREDENTIALS_FILE}"

if [ ! -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
fi  

if [ -z "${WEBROOT_DIR}" ] || [ -z "${PHPBB_DB_NAME}" ] \
   [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_PASSWORD}" ] || \
   ; then

  catastrophicError "phpBB cleaner can't run with these variables undefined:

  WEBROOT_DIR:               ##${WEBROOT_DIR}##
  MYSQL_USER:                ##${MYSQL_USER}##
  MYSQL_HOST:                ##${MYSQL_HOST}##
  MYSQL_PASSWORD:            ##${MYSQL_PASSWORD_HIDDEN}##"
  PHPBB_DB_NAME:             ##${PHPBB_DB_NAME}##
  exit
fi

if [ ! -d "${WEBROOT_DIR}forum" ]; then
  catastrophicError "phpBB directory ##${WEBROOT_DIR}forum## not found!"
fi

fxTitle "Deleting anonymous user sessions..."
echo mysqll -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e "DELETE FROM ${PHPBB_DB_NAME}.phpbb_sessions WHERE session_user_id = 1"
