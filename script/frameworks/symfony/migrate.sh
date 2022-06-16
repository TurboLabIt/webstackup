#!/usr/bin/env bash
## Standard Symfony migration routine by WEBSTACKUP
# ln -s "/usr/local/turbolab.it/webstackup/script/filesystem/symfony-migrate.sh" "scripts/migrate.sh"

SCRIPT_NAME=symfony-migrate

source $(dirname $(readlink -f $0))/script_begin.sh
printHeader "🚕 migrate"

sudo -u "${EXPECTED_USER}" -H symfony console doctrine:migrations:migrate --no-interaction

source $(dirname $(readlink -f $0))/script_end.sh
