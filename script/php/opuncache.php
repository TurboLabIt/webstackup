<?php
echo "<pre>";
echo "opcache" . PHP_EOL;
echo "=======" . PHP_EOL;
echo opcache_reset()  ? "OPcache flushed OK" : "ALERT! OPcache did not flush!";
echo PHP_EOL;
echo "</pre>";
