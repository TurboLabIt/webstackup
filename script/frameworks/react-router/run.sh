## the SSR build is served by the app's own Node server, PORT from the env
function wsuNodeRun()
{
  sudo -u $EXPECTED_USER -H PORT=$NODE_PORT NODE_ENV=$NODE_ENV node server.js build/server/index.js
}

source "${WEBSTACKUP_SCRIPT_DIR}node.js/run.sh"
