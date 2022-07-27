#!/usr/bin/env bash

git config --global --add safe.directory "${PROJECT_DIR}"
GIT_BRANCH=$(git -C $PROJECT_DIR branch | grep \* | cut -d ' ' -f2-)

if [ -f "${PROJECT_DIR}env" ]; then

  APP_ENV=$(head -n 1 ${PROJECT_DIR}env)

elif [ "$GIT_BRANCH" = "master" ]; then

  APP_ENV=prod

elif [ "$GIT_BRANCH" = "staging" ]; then

  APP_ENV=staging

elif [ "$GIT_BRANCH" = "dev" ] || [[ "$GIT_BRANCH" = "dev-"* ]]; then

  APP_ENV=dev

fi
