<?php

require_once('php-fx.php');

// https://stackoverflow.com/questions/8893574/php-php-input-vs-post
$txtInputPayload = file_get_contents('php://input');
if( empty($txtInputPayload) ) {
  fxCatastrophicError("The payload is empy", 400);
}

try {
  
  $oInputPayload = json_decode($txtInputPayload, false);
  if( !is_object($oInputPayload) ) {
    throw new Exception();
  }
  
} catch(Exception $ex) {
  fxCatastrophicError("Bad payload", 400);
}

## Push payload docs
# https://support.atlassian.com/bitbucket-cloud/docs/event-payloads/#Push

if( empty($oInputPayload->push) ) {
  fxCatastrophicError("Try to PUSH harder", 200);
}

$oChangesNew = $oInputPayload->push->changes[0]->new;

if( empty($oChangesNew) ) {
  fxCatastrophicError("No changes", 200);
}

if( $oChangesNew->type != "branch" ) {
  fxCatastrophicError("Not a branch op", 200);
}

$branch = $oChangesNew->name ?? 'unknown-branch';

if( !in_array($branch, ['master', 'main', 'staging']) ) {
  fxCatastrophicError("Not an approved branch", 200);
}

if( !empty($_GET["task"]) ) {
  $_GET["task"] = str_ireplace("BRANCH-NAME", $branch, $_GET["task"]);
}

require_once('async-runner-request.php');
