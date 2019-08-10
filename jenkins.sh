#!/bin/bash
git pull
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
