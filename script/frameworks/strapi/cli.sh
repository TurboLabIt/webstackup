## Strapi CLI: https://docs.strapi.io/cms/cli
#
# Examples:
#   scripts/cli.sh admin:create-user --firstname=Jane --email=jane@my-app.com --password=***
#   scripts/cli.sh export --no-encrypt -f backup/strapi-export
#   scripts/cli.sh telemetry:disable
fxHeader "🎶 strapi CLI"

## https://github.com/TurboLabIt/webstackup/blob/master/script/node.js/node_script_begin.sh
source "${WEBSTACKUP_SCRIPT_DIR}node.js/node_script_begin.sh"

sudo -u $EXPECTED_USER -H NODE_ENV=$NODE_ENV npm run strapi -- "$@"
