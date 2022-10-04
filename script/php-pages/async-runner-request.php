<?php

require_once('php-fx.php');

foreach(["app", "task", "secret"] as $param) {

  $value = $_GET[$param] ?? '';
  $value = strip_tags($value);
  $value = str_replace(['\\', '/', '*', '?', '"', "'", '<', '>', '|'], '', $value);
  $value = trim($value);

  if( empty($value) ) {
    fatalError("Please provide the required parameters", 400);
  }

  $$param = $value;
}

$filename = "/tmp/async-runner-request-$app-$task-$secret";

$writeResult = file_put_contents($filename, date('Y-m-d H:i:s'));

if(!$writeResult) {
  fatalError("Request file writing FAILED", 500);
}

chmod($filename, 0666);

http_response_code(202);
echo "✅ OK " . basename($filename) . " at " . file_get_contents($filename);
