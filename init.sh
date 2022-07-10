#!/bin/bash

export my_dir=$(pwd)
export PATH="$(pwd)/bin:${PATH}"

echo "Loading configuration..."
source "${my_dir}"/config.sh

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Please set GITHUB_TOKEN before continuing."
    exit 1
fi

git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"

mkdir -p "${ROM_DIR}"
cd "${ROM_DIR}"

source "${my_dir}"/sync.sh
