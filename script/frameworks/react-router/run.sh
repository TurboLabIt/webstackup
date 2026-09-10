## the SSR build is served by the app's own Node server, PORT from the env.
## Unlike `react-router dev` (Vite's loadEnv), server.js doesn't read .env by itself, and sudo's
## env_reset strips every variable but the ones passed on its command line: --env-file makes
## node load the project .env (API_BASE_URL, APP_KEY, ...). The real env (PORT, NODE_ENV) wins
## over the file, like dotenv: https://nodejs.org/api/cli.html#--env-fileconfig
function wsuNodeRun()
{
  local WSU_NODE_ENV_FILE="${PROJECT_DIR}.env"
  local WSU_NODE_ENV_FILE_ARG=

  if [ -f "${WSU_NODE_ENV_FILE}" ]; then
    WSU_NODE_ENV_FILE_ARG="--env-file=${WSU_NODE_ENV_FILE}"
  else
    fxWarning "No ##${WSU_NODE_ENV_FILE}## found: the server will run with PORT and NODE_ENV only"
  fi

  sudo -u $EXPECTED_USER -H PORT=$NODEJS_PORT NODE_ENV=$NODE_ENV node ${WSU_NODE_ENV_FILE_ARG} server.js build/server/index.js
}

source "${WEBSTACKUP_SCRIPT_DIR}node.js/run.sh"
