LOGGED_USER_BASHRC=$(fxGetUserHomePath $(logname)).bashrc
if [ "$APP_ENV" = 'dev' ] && [ -f  "${SCRIPT_DIR}bashrc-dev.sh" ] && ! grep -q "scripts/bashrc-dev.sh" "${LOGGED_USER_BASHRC}"; then

  echo "" >> "${LOGGED_USER_BASHRC}"
  echo "## Webstackup dev" >> "${LOGGED_USER_BASHRC}"
  echo "source ${SCRIPT_DIR}bashrc-dev.sh" >> "${LOGGED_USER_BASHRC}"
  fxOK "${LOGGED_USER_BASHRC} has been patched (dev)"
fi
