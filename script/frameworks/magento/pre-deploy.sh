if [ ! -d "${MAGENTO_DIR}" ]; then
  return 0
fi

N98_MAGERUN_FILE=/usr/local/bin/n98-magerun2

if [ ! -f "${N98_MAGERUN_FILE}" ]; then
  fxTitle "Installing n98-magerun2 from source..."
  curl -o "${N98_MAGERUN_FILE}" https://files.magerun.net/n98-magerun2.phar
  chmod u=rwx,go=rx "${N98_MAGERUN_FILE}"
fi

fxTitle "🧙 Switching to Magento..."
cd "${MAGENTO_DIR}"
pwd

fxTitle "⚙️ Entering maintenance mode..."
wsuMage maintenance:enable

fxTitle "Replace fastcgi_backend (prevents naming conflicts)..."
sed -i 's| fastcgi_backend;| fastcgi_backend_${APP_NAME};|g' ${MAGENTO_DIR}nginx.conf.sample
