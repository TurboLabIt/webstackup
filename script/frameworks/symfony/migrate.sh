## Run Symfony migration by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/migrate.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/frameworks/symfony/migrate-starter.sh && sudo chmod u=rwx,go=rx scripts/migrate.sh
#
# 1. You should now git commit your copy
#
# Tip: after the first `deploy.sh`, you can `zzmigrate` directly

SCRIPT_NAME=symfony-migrate
fxHeader "🚕 migrate"

showPHPVer

if [ -z "${PROJECT_DIR}" ] || [ ! -d "${PROJECT_DIR}" ]; then
  fxCatastrophicError "📁 PROJECT_DIR not set"
fi

cd "$PROJECT_DIR"

wsuSymfony console doctrine:migrations:migrate --no-interaction
