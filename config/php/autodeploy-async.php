<?php
$appName = $_GET["app-name"] ?? null;
$appName = strtolower(strip_tags($appName));
$appName = str_replace(['\\', '/'], '', $appName);
$appName = trim($appName);

if( empty($appName) ) {
 throw new InvalidArgumentException("Please provide the name of the application to autodeploy");
}

$filename = 'autodeploy-async-request-' . $appName;

file_put_contents($filename, date('Y-m-d H:i:s'));
