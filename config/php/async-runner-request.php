<?php
foreach(["app-name", "task-name", "secret"] as $param) {
  
  $value = $_GET[$param] ?? null;
  $value = strip_tags($value);
  $value = str_replace(['\\', '/', '*', '?', '"', "'", '<', '>', '|'], '', $value);
  $value = trim($value);
  
  if( empty($value) ) {
    throw new InvalidArgumentException("Please provide the required parameters");
  }
  
  $$param = $value;
}

$filename = "/tmp/async-runner-request-${app-name}-${task-name}";

$writeResult = file_put_contents($filename, $secret);

if(!$writeResult) {
 throw new RuntimeException("Request file writing FAILED");
}

chmod($filename, 0666);

echo "OK ${app-name}/${task-name} with secret ##" . $secret . "##";
