<?php

function fxCatastrophicError(string $message, int $httpStatus)
{
  http_response_code($httpStatus);
  die("🛑 " . $message);
}
