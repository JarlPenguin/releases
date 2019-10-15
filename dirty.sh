#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}/config.sh"

if [ "${GITHUB_TOKEN}" == "" ] || [ "${TELEGRAM_CHAT}" == "" ] || [ "${TELEGRAM_TOKEN}" == "" ]; then
    echo "Please set GITHUB_TOKEN, TELEGRAM_CHAT, and TELEGRAM_TOKEN before continuing."
    exit 1
fi

# Email for git
git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"

cd "${ROM_DIR}"

source "${my_dir}/sync.sh"
