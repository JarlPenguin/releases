#!/bin/bash
. config.sh
export GITHUB_TOKEN=""
export TELEGRAM_TOKEN=""
export TELEGRAM_CHAT=""
export JENKINS_URL="$JENKINS_URL"

if [ ! -d "$outdir" ]; then
. clean.sh
else
. dirty.sh
fi
