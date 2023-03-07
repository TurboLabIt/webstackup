echo ""

## Fix path (for cron)
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

## https://github.com/TurboLabIt/webstackup/blob/master/script/base.sh
source "/usr/local/turbolab.it/webstackup/script/base.sh"

ZZ_CMD_SUFFIX=0

WSU_FRAMEWORK_BEGIN=${WEBSTACKUP_SCRIPT_DIR}frameworks/${PROJECT_FRAMEWORK}/script_begin.sh
if [ -f "${WSU_FRAMEWORK_BEGIN}" ]; then
  source "${WSU_FRAMEWORK_BEGIN}"
fi

## Enviroment variables and checks
if [ "$APP_ENV" = "prod" ]; then

  EXPECTED_USER=webstackup
  EMOJI=⚡
  LOCAL_CONFIG_DIR=${PROJECT_DIR}config/custom/prod/

elif [ "$APP_ENV" = "staging" ]; then

  EXPECTED_USER=webstackup
  EMOJI=🧪
  LOCAL_CONFIG_DIR=${PROJECT_DIR}config/custom/staging/

elif [[ "$APP_ENV" == "dev"* ]]; then

  EXPECTED_USER=$(logname)
  EMOJI=👨🏻‍💻
  LOCAL_CONFIG_DIR=${PROJECT_DIR}config/custom/dev/

else

  fxCatastrophicError "Unhandled env ##$APP_ENV## (branch: ##$GIT_BRANCH##)"
fi

cd "$PROJECT_DIR"
