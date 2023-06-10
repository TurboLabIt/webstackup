<?php
use Symfony\Component\Dotenv\Dotenv;

require 'vendor/autoload.php';

if (method_exists(Dotenv::class, 'bootEnv')) {
    (new Dotenv())->bootEnv('.env');
}
