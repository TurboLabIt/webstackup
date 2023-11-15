## Creat JWT Token on WordPress by WEBSTACKUP
#
# How to:
# 
# 1. Install https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/#installation on WordPress
#
# 1. set `PROJECT_FRAMEWORK=wordpress` in your project `script_begin.sh`
#
# 1. set `SITE_URL=https://my-app.com/` in your project `script_begin.sh`
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/wordpress-generate-jwt-token.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/wordpress-generate-jwt-token.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy

if [ -z "${JWT_USER_NAME}" ]; then
  JWT_USER_NAME=jwt-api-post-user
fi

while [ -z "$JWT_USER_PASSWORD" ]; do

  echo "🤖 Provide the password of the ##${JWT_USER_NAME}## user on ${SITE_URL}... "
  read -p ">> " JWT_USER_PASSWORD  < /dev/tty

done

fxTitle "Response"
curl -i -X POST --USER "${SITE_HTTP_BASIC_AUTH_USER_PASSWORD}" "${SITE_URL}wp-json/jwt-auth/v1/token' -d "username=$JWT_USER_NAME&password=$JWT_USER_PASSWORD"

source "${SCRIPT_DIR}script_end.sh"
