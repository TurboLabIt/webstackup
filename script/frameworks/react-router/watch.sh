## `react-router dev` (Vite) takes the port from --port, not from the env
function wsuNodeWatch()
{
  echo "y" | sudo -u $EXPECTED_USER -H npm run dev -- --port $NODEJS_PORT
}

source "${WEBSTACKUP_SCRIPT_DIR}node.js/watch.sh"
