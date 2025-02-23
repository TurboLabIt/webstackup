if [ ! -z "$(command -v nginx)" ]; then
  echo "Reloading NGINX...."
  sudo nginx -t && sudo service nginx reload
fi


if [ ! -z "$(command -v apache2)" ]; then
  echo "Reloading APACHE...."
  sudo apachectl configtest && sudo service apache2 reload
fi


if [ ! -z "$(command -v postfix)" ]; then
  echo "Reloading POSTFIX...."
  sudo postfix check && sudo service postfix reload
fi


if [ ! -z "$(command -v dovecot)" ]; then
  echo "Reloading DOVECOT...."
  sudo doveconf -n >/dev/null && service dovecot reload
fi
