#!/bin/bash
export branch=$(git branch | grep \* | cut -d ' ' -f2)
git fetch --all
git checkout origin/"$branch"
git branch -D "$branch"
git checkout -b "$branch"
. config.sh
export GITHUB_TOKEN=""
export TELEGRAM_TOKEN=""
export TELEGRAM_CHAT=""
export BUILD_NUMBER=""
if [ ! -d "$ROM_DIR"/out ]; then
. clean.sh
else
. dirty.sh
fi
