#!/bin/bash
export branch=$(git branch | grep \* | cut -d ' ' -f2)
if [ ! -f /usr/bin/telegram ]; then
    sudo install bin/telegram /usr/bin
elif [ ! -f /usr/bin/github-release ]; then
    sudo install bin/github-release /usr/bin
fi
git checkout -- .
git fetch --all
git checkout origin/"${branch}"
git branch -D "${branch}"
git checkout -b "${branch}"
source config.sh
export GITHUB_TOKEN=""
export TELEGRAM_TOKEN=""
export TELEGRAM_CHAT=""
export BUILD_NUMBER=""
if [ ! -d "${ROM_DIR}/out" ]; then
    source clean.sh
else
    source dirty.sh
fi
