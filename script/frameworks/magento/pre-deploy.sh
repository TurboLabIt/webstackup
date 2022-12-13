if [ ! -d "${MAGENTO_DIR}" ]; then
  return 0
fi

fxTitle "Installing required PHP extensions and support packages..."
if [ ! -z "${PHP_VER}" ]; then

  ## see: https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/prerequisites/php-settings.html?mt=false#verify-installed-extensions

  apt update
  apt install \
    php${PHP_VER}-bcmath php${PHP_VER}-ctype php${PHP_VER}-curl \
    php${PHP_VER}-dom php${PHP_VER}-fileinfo php${PHP_VER}-gd \
    php${PHP_VER}-iconv php${PHP_VER}-intl php${PHP_VER}-json \
    php${PHP_VER}-xml php${PHP_VER}-mbstring php${PHP_VER}-mysql \
    php${PHP_VER}-simplexml php${PHP_VER}-soap php${PHP_VER}-sockets \
    php${PHP_VER}-xmlwriter php${PHP_VER}-xsl php${PHP_VER}-zip \
    libxml2 openssl \
  -y

else

  fxWarning "PHP_VER is undefined, skipping"
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

fxTitle "🥞 Backing up current DB..."
DB_DUMP_SQL=${PROJECT_DIR}backup/dbdump_${APP_ENV}_pre-deploy.sql
fxMessage "$DB_DUMP_SQL"
rm -f "${DB_DUMP_SQL}"
wsuN98MageRun db:dump --strip="@stripped" --no-tablespaces "${DB_DUMP_SQL}"
rm -f "${DB_DUMP_SQL}.gz"
## please don't add --best to gzip. It's super-slow+ineffective (4.3 GB -> 594 MB vs 607 MB)
gzip "${DB_DUMP_SQL}" &

fxTitle "Replace fastcgi_backend (prevents naming conflicts)..."
sed -i 's| fastcgi_backend;| fastcgi_backend_${APP_NAME};|g' ${MAGENTO_DIR}nginx.conf.sample
