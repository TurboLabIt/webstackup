#!/usr/bin/env bash
### Generic, framework-related commands
function wsuSourceFrameworkScript()
{
  if [ -z "${PROJECT_FRAMEWORK}" ]; then
    fxCatastrophicError "wsuSourceFrameworkScript: a defined PROJECT_FRAMEWORK is required"
  fi
  
  if [ -z "$1" ]; then
    fxCatastrophicError "wsuSourceFrameworkScript: provide the script to source"
  fi
  
  local RUNNABLE="${WEBSTACKUP_SCRIPT_DIR}frameworks/${PROJECT_FRAMEWORK}/${1}.sh"
  if [ -f "${RUNNABLE}" ]; then
    source ${RUNNABLE}
    source ${SCRIPT_DIR}/script_end.sh
  else
    fxInfo "No $(basename ${RUNNABLE} .sh) script available for your ##${PROJECT_FRAMEWORK}## framework"
  fi
}
