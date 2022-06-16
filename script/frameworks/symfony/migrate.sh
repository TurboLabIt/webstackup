#!/usr/bin/env bash
## Standard Symfony migration routine by WEBSTACKUP
# printTitle "💫 Copying Symfony scripts from webstackup..."
# cp "${WEBSTACKUP_SCRIPT_DIR}frameworks/symfony/migrate.sh" "${SCRIPT_DIR}"

SCRIPT_NAME=symfony-migrate

source $(dirname $(readlink -f $0))/script_begin.sh
printHeader "🚕 migrate"

sudo -u "${EXPECTED_USER}" -H symfony console doctrine:migrations:migrate --no-interaction

source $(dirname $(readlink -f $0))/script_end.sh
