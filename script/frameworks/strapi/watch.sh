## `strapi develop`: server auto-reload + admin panel hot reload
## https://docs.strapi.io/cms/cli#strapi-develop
## PORT wins over the one in .env (dotenv doesn't override the env)
function wsuNodeWatch()
{
  echo "y" | sudo -u $EXPECTED_USER -H PORT=$NODE_PORT npm run develop
}

source "${WEBSTACKUP_SCRIPT_DIR}node.js/watch.sh"
