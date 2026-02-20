fxHeader "🧹 phpBB cleaner"

MYSQL_CREDENTIALS_FILE=/etc/turbolab.it/mysql.conf
if [ ! -e "${MYSQL_CREDENTIALS_FILE}" ]; then
  fxCatastrophicError "Credentials file ${MYSQL_CREDENTIALS_FILE} not found!"
fi

source "${MYSQL_CREDENTIALS_FILE}"

if [ ! -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
fi  

if [ -z "${WEBROOT_DIR}" ] || [ -z "${PHPBB_DB_NAME}" ] || \
   [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_HOST}" ] || [ -z "${MYSQL_PASSWORD}" ] \
   ; then

  catastrophicError "phpBB cleaner can't run with these variables undefined:

  WEBROOT_DIR:               ##${WEBROOT_DIR}##
  MYSQL_USER:                ##${MYSQL_USER}##
  MYSQL_HOST:                ##${MYSQL_HOST}##
  MYSQL_PASSWORD:            ##${MYSQL_PASSWORD_HIDDEN}##
  PHPBB_DB_NAME:             ##${PHPBB_DB_NAME}##"
  exit
fi

if [ ! -d "${WEBROOT_DIR}forum" ]; then
  catastrophicError "phpBB directory ##${WEBROOT_DIR}forum## not found!"
fi


fxTitle "Deleting anonymous user sessions..."
mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e "
  DELETE FROM ${PHPBB_DB_NAME}.phpbb_sessions WHERE session_user_id = 1 AND session_last_visit <= UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 10 MINUTE));

  SELECT ROW_COUNT() as 'Sessions deleted'
"


fxTitle "Invalidate passwords for users: 《 inactive 2+ years 》 OR 《 never logged in but registered 6+ months ago 》..."
WSU_PHPBB_INVALIDATED_PASSWORD='$H$9webstackup.phpbb.cleaner.invalidated.password.hash'
WSU_PHPBB_INVALIDATED_DATE=$(date '+%Y-%m-%d')

mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e "
  UPDATE ${PHPBB_DB_NAME}.phpbb_users 
  SET user_password = '${WSU_PHPBB_INVALIDATED_PASSWORD}.${WSU_PHPBB_INVALIDATED_DATE}'
  WHERE (
    (user_lastvisit > 0 AND user_lastvisit < (UNIX_TIMESTAMP() - (2 * 365 * 24 * 60 * 60)))
    OR 
    (user_lastvisit = 0 AND user_regdate < (UNIX_TIMESTAMP() - (182 * 24 * 60 * 60)))
  )
    AND user_type != 2
    AND user_password NOT LIKE '${WSU_PHPBB_INVALIDATED_PASSWORD}%';

  SELECT ROW_COUNT() as 'Passwords invalidated'
"

mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e "
  SELECT
      user_id AS id, username, user_email AS email,
      DATE(FROM_UNIXTIME(user_regdate)) as reg_date,
      CASE 
        WHEN user_lastvisit = 0 THEN 'Never visited' 
        ELSE DATE(FROM_UNIXTIME(user_lastvisit)) 
      END as last_visit,
      CASE
        WHEN user_lastvisit = 0 THEN 'Never logged in'
        ELSE CONCAT('Inactive for ', DATEDIFF(NOW(), FROM_UNIXTIME(user_lastvisit)), ' days')
      END as status
  FROM ${PHPBB_DB_NAME}.phpbb_users
  WHERE
    user_password = '${WSU_PHPBB_INVALIDATED_PASSWORD}.${WSU_PHPBB_INVALIDATED_DATE}'
  ORDER BY user_id ASC
"


fxTitle "Deleting sessions for users with an invalidated password..."
mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e "
  DELETE ${PHPBB_DB_NAME}.phpbb_sessions
  FROM ${PHPBB_DB_NAME}.phpbb_sessions
  INNER JOIN ${PHPBB_DB_NAME}.phpbb_users
  ON ${PHPBB_DB_NAME}.phpbb_sessions.session_user_id = ${PHPBB_DB_NAME}.phpbb_users.user_id
  WHERE
     ${PHPBB_DB_NAME}.phpbb_users.user_password LIKE '${WSU_PHPBB_INVALIDATED_PASSWORD}%';

  SELECT ROW_COUNT() as 'Sessions deleted';

  DELETE ${PHPBB_DB_NAME}.phpbb_sessions_keys
  FROM ${PHPBB_DB_NAME}.phpbb_sessions_keys
  INNER JOIN ${PHPBB_DB_NAME}.phpbb_users
  ON ${PHPBB_DB_NAME}.phpbb_sessions_keys.user_id = ${PHPBB_DB_NAME}.phpbb_users.user_id
  WHERE
     ${PHPBB_DB_NAME}.phpbb_users.user_password LIKE '${WSU_PHPBB_INVALIDATED_PASSWORD}%';

  SELECT ROW_COUNT() as 'Remember-me tokens deleted';
"
