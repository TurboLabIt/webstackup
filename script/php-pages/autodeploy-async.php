<?php

require_once('php-fx.php');

if( $_SERVER['REQUEST_METHOD'] !== 'POST' ) {
    fxCatastrophicError('Method not allowed', 405);
}

if( stripos($_SERVER['CONTENT_TYPE'] ?? '', 'application/json') !== 0 ) {
    fxCatastrophicError('Unsupported Media Type', 415);
}

// https://stackoverflow.com/questions/8893574/php-php-input-vs-post
$txtInputPayload = file_get_contents('php://input');
if( empty($txtInputPayload) ) {
    fxCatastrophicError("The payload is empty", 422);
}

try {

    $oInputPayload = json_decode($txtInputPayload, false);
    if( !is_object($oInputPayload) || json_last_error() !== JSON_ERROR_NONE ) {
        throw new Exception();
    }

} catch(Exception $ex) {
    fxCatastrophicError("Bad payload", 422);
}


if( ($_SERVER['HTTP_X_GITHUB_EVENT'] ?? null) == 'push' ) {

    $oChangesNew = empty($oInputPayload->commits) ? null : $oInputPayload->commits;

    $ref = empty($oInputPayload->ref) ? '' : $oInputPayload->ref;

    if( strpos($ref, 'refs/heads/') !== 0 ) {
        fxCatastrophicError('GitHub push is not a branch (likely a tag)', 202);
    }

    $branch = substr($ref, strlen('refs/heads/')) ?: null;

} elseif( !empty($oInputPayload->push) ) {

    ## Push payload docs
    # https://support.atlassian.com/bitbucket-cloud/docs/event-payloads/#Push

    $oChangesNew = empty($oInputPayload->push->changes[0]->new) ? null : $oInputPayload->push->changes[0]->new;

    if( ($oChangesNew->type ?? null) !== "branch" ) {
        fxCatastrophicError("Not a Bitbucket branch op", 200);
    }

    $branch = empty($oChangesNew->name) ? null : $oChangesNew->name;

} else {

    fxCatastrophicError("Try to PUSH harder", 202);
}


if( empty($branch) ) {
    fxCatastrophicError("Undefined branch name", 202);
}

if( empty($oChangesNew) ) {
    fxCatastrophicError("No changes", 202);
}

$task = $_GET["task"] ?? '';
unset($_GET["task"]);
$taskClean = preg_replace('/[^A-Za-z0-9._-]/', '', $task);

if( !empty($taskClean) ) {
    $_GET["task"] = str_ireplace("BRANCH-NAME", $branch, $taskClean);
}


require_once('async-runner-request.php');
