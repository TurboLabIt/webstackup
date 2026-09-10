## `strapi start`: the production server (no admin panel rebuild, Content-Type Builder disabled)
## https://docs.strapi.io/cms/cli#strapi-start
## PORT wins over the one in .env (dotenv doesn't override the env)
function wsuNodeRun()
{
  sudo -u $EXPECTED_USER -H PORT=$NODEJS_PORT NODE_ENV=$NODE_ENV npm run start
}

source "${WEBSTACKUP_SCRIPT_DIR}node.js/run.sh"
