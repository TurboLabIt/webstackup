# How to autodeploy

To activate the autodeploy routine on your staging env:

1. from your repo, setup a webhook on push to 
   `https://my-app.com/autodeploy-async.php?app=my-app&task=autodeploy-BRANCH-NAME&secret=123456789`
   Yes, use the literal `BRANCH-NAME`. It will be replaced as expected
   
1. check your `config/custom/staging/cron`. 
   You should have a `async-runner.sh ${AUTODEPLOY_FILENAME_TO_CHECK}` line, like this:
   [my-app-template/config/custom/staging/cron](https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/staging/cron)
   The `AUTODEPLOY_FILENAME_TO_CHECK=` value is critical: it MUST match the args from you webhook
   (DO look at the example linked above)
   
1. check your `config/custom/staging/nginx`.
   It MUST include `45_autodeploy-async.conf` like this:
   [my-app-template/config/custom/staging/nginx.conf](https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/staging/nginx.conf)
   
1. run `/var/www/my-app/scripts/deploy.sh` on your staging env. It will link
   [autodeploy-async.php](https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/staging/cron](https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/autodeploy-async.php)
   to `my-app/<webroot>` directory
   
1. run a test commit on `my-app` and merge it to staging.
   As soon as the webhook runs, `my-app` should autodeploy (via `script/deploy.sh fast`)


Please check the HTTPS status code of `autodeploy-async.php`:

* **200**: the request is OK, but is non-actionable.
   Most likely: a push to a different branch

* **202**: The request was accepted! If a matching cron
   exists, it will run
   
40x and 50x are errors. Check the response body for an hint!
