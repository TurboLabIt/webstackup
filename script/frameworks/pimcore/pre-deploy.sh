fxTitle "Installing required PHP extensions and support packages..."
if [ ! -z "${PHP_VER}" ]; then

  apt update
  apt install \
    php${PHP_VER}-bcmath php${PHP_VER}-ctype php${PHP_VER}-curl \
    php${PHP_VER}-dom php${PHP_VER}-fileinfo php${PHP_VER}-gd \
    php${PHP_VER}-iconv php${PHP_VER}-intl \
    php${PHP_VER}-xml php${PHP_VER}-mbstring php${PHP_VER}-mysql \
    php${PHP_VER}-simplexml php${PHP_VER}-soap php${PHP_VER}-sockets \
    php${PHP_VER}-xmlwriter php${PHP_VER}-xsl php${PHP_VER}-zip \
    libxml2 openssl \
  -y

else

  fxWarning "PHP_VER is undefined, skipping 🦘"
fi
