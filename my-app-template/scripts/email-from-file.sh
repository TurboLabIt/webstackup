#!/usr/bin/env bash

source $(dirname $(readlink -f $0))/script_begin.sh

EMAIL_FROM_NAME="My App Name"
EMAIL_FROM_ADDRESS="no-reply@my-app.com"
EMAIL_SUBJECT="🥳 The new site is ready!"
HTML_FILE_PATH="${PROJECT_DIR}email/new-site-ready.html"
RECIPIENTS_LIST="${PROJECT_DIR}var/recipients.txt"

source "${WEBSTACKUP_SCRIPT_DIR}mail/send-test-email.sh"
