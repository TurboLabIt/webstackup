#!/usr/bin/env bash
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/react-router-install.sh

source $(dirname $(readlink -f $0))/script_begin.sh

## Leave it empty to get the official default template (TypeScript + Vite + Tailwind, SSR on).
## Anything accepted by `create-react-router --template` works: https://github.com/remix-run/react-router-templates
#REACT_ROUTER_TEMPLATE=remix-run/react-router-templates/vercel
REACT_ROUTER_TEMPLATE=

## Leave it empty to get the latest React Router
#REACT_ROUTER_VERSION=8.3.1
REACT_ROUTER_VERSION=

source ${WEBSTACKUP_SCRIPT_DIR}node.js/react-router_new.sh

source "${SCRIPT_DIR}/script_end.sh"
