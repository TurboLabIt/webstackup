## 🚨 WARNING 🚨
#
# This file is under version control!
# DO NOT EDIT DIRECTLY - If you do, you'll loose your changes!
#
# The original file is in `/var/www/my-app/config/custom/`
#
# You MUST:
#
# 1. edit the original file on you PC
# 2. Git-commit+push the changes
# 3. run `sudo bash /var/www/my-app/scripts/deploy.sh`
#
# ⚠️ This file is SHARED among staging|prod ⚠️
#
# Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/varnish.vcl

vcl 4.1;

## https://github.com/TurboLabIt/webstackup/blob/master/config/varnish/base-backend-localhost.vcl
include "/usr/local/turbolab.it/webstackup/config/varnish/base-backend-localhost.vcl";

## https://github.com/TurboLabIt/webstackup/blob/master/config/varnish/base.vcl
include "/usr/local/turbolab.it/webstackup/config/varnish/base.vcl";


sub vcl_recv {
  # Happens before we check if we have this in cache already.
  #
  # Typically you clean up the request here, removing cookies you don't need,
  # rewriting the request, etc.
    
  ## Webstackup base Varnish config.
  # See: https://github.com/TurboLabIt/webstackup/blob/master/config/varnish/base.vcl
  call wsu_base_recv;
}


sub vcl_backend_response {
  # Happens after we have read the response headers from the backend.
  #
  # Here you clean the response headers, removing silly Set-Cookie headers
  # and other mistakes your backend does.

  ## Webstackup base Varnish config.
  # See: https://github.com/TurboLabIt/webstackup/blob/master/config/varnish/base.vcl
  call wsu_base_backend_response;
}


sub vcl_deliver {
  # Happens when we have all the pieces we need, and are about to send the
  # response to the client.
  #
  # You can do accounting or modifying the final object here.
}
