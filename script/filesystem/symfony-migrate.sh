#!/usr/bin/env bash
SCRIPT_NAME=symfony-migrate

source $(dirname $(readlink -f $0))/script_begin.sh
printHeader "🚕 migrate"

sudo -u "${EXPECTED_USER}" -H symfony console doctrine:migrations:migrate --no-interaction

source $(dirname $(readlink -f $0))/script_end.sh
