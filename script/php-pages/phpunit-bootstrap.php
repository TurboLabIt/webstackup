<?php
// 📚 https://github.com/TurboLabIt/webstackup/edit/master/script/php-pages/phpunit-bootstrap.php
use Symfony\Component\Dotenv\Dotenv;
use Symfony\Component\ErrorHandler\ErrorHandler;

require 'vendor/autoload.php';

$arrEnvFiles = [
    '.env',
    '.env.local',
    '.env.dev',
    '.env.dev.local'
];

if( file_exists('.env.local.php') ) {
    $arrDumpedEnv = include '.env.local.php';
}

$realEnv = $arrDumpedEnv["APP_ENV"] ?? 'test';

$arrEnvFiles =
    array_merge($arrEnvFiles, [
        ".env.$realEnv",
        ".env.$realEnv.local"
    ]);

if( method_exists(Dotenv::class, 'bootEnv') ) {

    foreach($arrEnvFiles as $envFile) {

        if( file_exists($envFile) ) {
            (new Dotenv())->bootEnv($envFile);
        }
    }
}

// https://github.com/symfony/symfony/issues/53812#issuecomment-1962311843
if( method_exists(ErrorHandler::class, 'register') ) {
    ErrorHandler::register(null, false);
}
