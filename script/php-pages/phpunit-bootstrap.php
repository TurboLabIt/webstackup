<?php
use Symfony\Component\Dotenv\Dotenv;

require 'vendor/autoload.php';

$arrEnvFiles = [
    '.env',
    '.env.local'
];

if( file_exists('.env.local.php') ) {
    $arrDumpedEnv = include '.env.local.php';
}

$realEnv = $arrDumpedEnv["APP_ENV"] ?? 'dev';

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
