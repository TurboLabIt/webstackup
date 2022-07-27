DOWEEK="$(date +'%u')"

## Header (green)
WEBSTACKUP_FRAME="O===========================================================O"
printHeader ()
{
  STYLE='\033[42m'
  RESET='\033[0m'

  echo ""
  echo -n -e $STYLE
  echo ""
  echo "$WEBSTACKUP_FRAME"
  echo " --> $1 - $(date) on $(hostname)"
  echo "$WEBSTACKUP_FRAME"
  echo -e $RESET
}


function printTheEnd ()
{
  echo ""
  echo "The End"
  echo $(date)
  
  if [ ! -z "$TIME_START" ]; then
    echo "$((($(date +%s)-$TIME_START)/60)) min."
  fi
  
  echo "$WEBSTACKUP_FRAME"
  cd $INITIAL_DIR
  exit
}


function catastrophicError ()
{
  STYLE='\033[41m'
  RESET='\033[0m'

  echo ""
  echo -n -e $STYLE
  echo "vvvvvvvvvvvvvvvvvvvv"
  echo "Catastrophic error!!"
  echo "^^^^^^^^^^^^^^^^^^^^"
  echo "$1"
  echo -e $RESET
  
  printTheEnd
}


rootCheck ()
{
  if ! [ $(id -u) = 0 ]; then
    catastrophicError "This script must run as ROOT"
  fi
}


devOnlyCheck ()
{
  if [ "$APP_ENV" != "dev" ]; then
    catastrophicError "This script is for DEV only!"
  fi
}


lockCheck ()
{
  local LOCKFILE=${1}.lock
  if [ -z "$2" ]; then
    LOCKFILE_TIMEOUT=120
  else
    LOCKFILE_TIMEOUT=$2
  fi 
  
  if [ -f "${LOCKFILE}" ] && [ ! -z `find "${LOCKFILE}" -mmin -${LOCKFILE_TIMEOUT}` ]; then
    catastrophicError "Lockfile detected. It looks like this script is already running!
To override:
sudo rm -f \"$LOCKFILE\""

    echo ""
    ls -lah "${LOCKFILE}"

    echo ""
    exit
  fi

  touch "$LOCKFILE"
  printMessage "Lock file created in ##${LOCKFILE}##"
}


removeLock ()
{
  local LOCKFILE=${1}.lock
  rm -f "${LOCKFILE}"
  printMessage "${LOCKFILE} deleted"
}


function printTitle ()
{
  STYLE='\033[44m'
  RESET='\033[0m'

  echo ""
  echo -n -e $STYLE
  echo "$1"
  printf '%0.s-' $(seq 1 ${#1})
  echo -e $RESET
  echo ""
}


function printMessage ()
{
  STYLE='\033[45m'
  RESET='\033[0m'

  echo ""
  echo -n -e $STYLE
  echo "$1"
  echo -e $RESET
  echo ""
}


printLightWarning ()
{
  STYLE='\033[33m'
  RESET='\033[0m'

  echo ""
  echo -n -e $STYLE
  echo "$1"
  echo -e $RESET
  echo ""
}




function checkExecutingUser ()
{
  ## Current user
  CURRENT_USER=$(whoami)

  if [ "$CURRENT_USER" != "$1" ]; then

    echo "vvvvvvvvvvvvvvvvvvvv"
    echo "Catastrophic error!!"
    echo "^^^^^^^^^^^^^^^^^^^^"
    echo "Wrong user: please run this script as: "
    echo "sudo -u $1 -H bash \"$SCRIPT_FULLPATH\""

    printTheEnd
  fi
}


function browsePage
{
    echo "Browsing ##${1}##..."
    curl --insecure --location --show-error --write-out "%{http_code}" "${1}"
    echo
}


function zzcache()
{
  ZZCACHE_INITIAL_DIR=$(pwd)
  cd "$PROJECT_DIR"
  XDEBUG_MODE=off symfony console cache:clear
  cachetool opcache:reset --fcgi=/run/php/${PHP_FPM}.sock
  cd "$ZZCACHE_INITIAL_DIR"
}


function flushOpcache()
{
  echo "flushOpcache is a TO DO"
}


function browse()
{
  BROWSEURL=$1
  echo ${BROWSEURL}
  curl --insecure --location --silent --show-error --output /dev/null --write-out "%{http_code}" ${BROWSEURL}
  echo
}


function playSoundLongOK()
{
  "${WEBSTACKUP_SCRIPT_DIR}notify/play-sound.sh" "${WEBSTACKUP_ASSET_DIR}sound/mario-stage-clear.wav"
}


function playSoundLongKO()
{
  "${WEBSTACKUP_SCRIPT_DIR}notify/play-sound.sh" "${WEBSTACKUP_ASSET_DIR}sound/mario-dies.wav"
}


function playSoundKO()
{
  "${WEBSTACKUP_SCRIPT_DIR}notify/play-sound.sh" "${WEBSTACKUP_ASSET_DIR}sound/cannon.wav"
}


