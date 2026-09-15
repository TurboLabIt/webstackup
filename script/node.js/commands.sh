#!/usr/bin/env bash
### READY-TO-RUN, FULLY CUSTOMIZED NODE.JS COMMANDS BY WEBSTACKUP
#
# wsuNodeKillPortOwner
#
# NODEJS_PORT


## Kill whatever is listening on NODEJS_PORT, so that the server about to start can bind it.
## Typical owners: a previous instance of the same app (a run.sh left in a detached terminal, the systemd unit
## while run.sh is started by hand, a watch.sh forgotten in an IDE terminal, ...).
## SIGTERM first, so that the app shuts down gracefully (Strapi closes its DB connections on it), SIGKILL after
## the grace period. `strapi develop` is a Node cluster: the listening socket belongs to the primary and the
## worker exits by itself when the primary dies (IPC channel closed), so killing the listening PID is enough.
function wsuNodeKillPortOwner()
{
  fxTitle "🚪 Checking port ##${NODEJS_PORT}##..."

  if [ -z "${NODEJS_PORT}" ]; then
    fxCatastrophicError "wsuNodeKillPortOwner: NODEJS_PORT is undefined"
  fi

  ## -H: no header. `ss -p` reveals the owner of other users' sockets only as root
  local WSU_PORT_PIDS=$(sudo ss -ltnpH "sport = :${NODEJS_PORT}" | grep -oE "pid=[0-9]+" | cut -d= -f2 | sort -u)
  if [ -z "${WSU_PORT_PIDS}" ]; then
    fxOK "Port ##${NODEJS_PORT}## is free"
    return 0
  fi

  local PID
  for PID in ${WSU_PORT_PIDS}; do

    ## who started it: sudo hides the human behind root/EXPECTED_USER, but the systemd unit doesn't lie:
    ## a login session scope means someone started it by hand, a .service means systemd did
    local PID_USER=$(ps -o user= -p "${PID}")
    local PID_CMD=$(ps -o args= -p "${PID}")
    local PID_SINCE=$(ps -o lstart= -p "${PID}")
    local PID_CWD=$(sudo readlink -f "/proc/${PID}/cwd" 2>/dev/null)
    local PID_UNIT=$(ps -o unit= -p "${PID}" | tr -d ' ')
    local PID_STARTED_BY
    case "${PID_UNIT}" in
      session-*.scope)
        local SESSION_ID=${PID_UNIT#session-}
        SESSION_ID=${SESSION_ID%.scope}
        local SESSION_USER=$(loginctl show-session "${SESSION_ID}" -p Name --value 2>/dev/null)
        PID_STARTED_BY="##${SESSION_USER:-${PID_USER}}## from login session ##${PID_UNIT}##"
        ;;
      *.service)
        PID_STARTED_BY="systemd unit ##${PID_UNIT}##"
        ;;
      *)
        PID_STARTED_BY="##${PID_USER}##"
        ;;
    esac

    fxWarning "Killing PID ##${PID}## (##${PID_CMD}##): listening on port ##${NODEJS_PORT}##, running as ##${PID_USER}## in ##${PID_CWD}## since ${PID_SINCE}, started by ${PID_STARTED_BY}"
    sudo kill -TERM "${PID}" 2>/dev/null
  done

  ## grace period for the graceful shutdown
  local WSU_KILL_GRACE_SECONDS=10
  local i
  for (( i = 0; i < WSU_KILL_GRACE_SECONDS; i++ )); do
    if [ -z "$(sudo ss -ltnH "sport = :${NODEJS_PORT}")" ]; then
      fxOK "Port ##${NODEJS_PORT}## is now free"
      return 0
    fi
    sleep 1
  done

  fxWarning "Port ##${NODEJS_PORT}## is still busy after ${WSU_KILL_GRACE_SECONDS} seconds: sending SIGKILL..."
  for PID in ${WSU_PORT_PIDS}; do
    sudo kill -KILL "${PID}" 2>/dev/null
  done
  sleep 1

  if [ -n "$(sudo ss -ltnH "sport = :${NODEJS_PORT}")" ]; then
    fxCatastrophicError "Port ##${NODEJS_PORT}## is still busy: $(sudo ss -ltnpH "sport = :${NODEJS_PORT}")"
  fi

  fxOK "Port ##${NODEJS_PORT}## is now free"
}
