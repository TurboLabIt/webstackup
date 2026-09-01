fxTitle "🤹 Setting node.js version..."
if [ ! -z "${NODEJS_VER}" ]; then
  sudo n "${NODEJS_VER}"
else
  fxInfo "No NODEJS_VER defined. Using default"
fi

fxTitle "🤹 node.js version in use"
sudo -u $EXPECTED_USER -H node --version


if [ -z "$NODE_PORT" ]; then
  NODE_PORT=5173
fi

fxTitle "🤹 NODE_PORT"
echo "$NODE_PORT"


NODE_MODULES_BIN_DIR="node_modules/.bin"
fxTitle "👮 Fixing permissions on ##${NODE_MODULES_BIN_DIR}##"
if [ -d "${NODE_MODULES_BIN_DIR}" ]; then
  ## every entry in .bin is a symlink into a package and `chmod -R` SKIPS symlinks, so it
  ## silently fixed nothing: naming each entry makes chmod dereference it and hit the real file
  sudo find "${NODE_MODULES_BIN_DIR}" -maxdepth 1 -exec chmod ug+x {} +
else
  fxInfo "Skipped (not found) 🦘"
fi

YARN_CMD="sudo -u $EXPECTED_USER -H COREPACK_ENABLE_DOWNLOAD_PROMPT=0 yarn"
