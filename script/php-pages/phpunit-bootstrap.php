<?php
// curl -o tests/bootstrap.php https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/php-pages/phpunit-bootstrap.php
use Symfony\Component\Dotenv\Dotenv;

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

$dotEnvLoaderExists = method_exists(Dotenv::class, 'bootEnv');
if($dotEnvLoaderExists) {
    foreach($arrEnvFiles as $envFile) {
        if( file_exists($envFile) ) {
            (new Dotenv())->bootEnv($envFile);
        }
    }
}

// https://github.com/symfony/symfony/issues/53812#issuecomment-1962311843
Symfony\Component\ErrorHandler\ErrorHandler::register(null, false);
