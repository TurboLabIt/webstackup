#!/usr/bin/env bash

SCRIPT_NAME=cleaner
source $(dirname $(readlink -f $0))/script_begin.sh

fxHeader "🧹 ${SCRIPT_NAME}"
rootCheck

#fxTitle "Deleting processed file..."
XML_PROCESSED_RETENTION_DAYS=20
#find "${PROJECT_DIR}var/xml/processed/"* -mtime +${XML_PROCESSED_RETENTION_DAYS} -name '*' -delete
#fxOK

#fxTitle "Deleting something else..."
#...

source ${SCRIPT_DIR}/script_end.sh
