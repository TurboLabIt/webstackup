<?php

$filename   = $argv[1];
$filecontent= file_get_contents($filename);
$newcontent = file_get_contents('https://api.wordpress.org/secret-key/1.1/salt/');
$regex      = preg_quote('/**#@+', '/') . '.+' . preg_quote('/**#@-*/', '/');
$regex      = '/' . $regex . '/ismu';

$result     = preg_replace($regex, '##PLACEHOLDER##', $filecontent);
$result     = str_replace('##PLACEHOLDER##', $newcontent, $result);

file_put_contents($filename, $result);
