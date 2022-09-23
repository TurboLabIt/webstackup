#!/usr/bin/env bash
curl -Lo .gitignore https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore?$(date +%s)
curl -Lo backup/.gitignore https://raw.githubusercontent.com/ZaneCEO/webdev-gitignore/master/.gitignore_contents?$(date +%s)

