#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}"/config.sh

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Please set GITHUB_TOKEN before continuing."
    exit 1
fi

# Email for git
git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"

mkdir -p "${ROM_DIR}"
cd "${ROM_DIR}"
make clean -j$(nproc --all)
make clobber -j$(nproc --all)

if [ ! -d "${ROM_DIR}/.repo" ]; then
echo "Initializing repository..."
repo init -u "${manifest_url}" -b "${branch}" --depth 1
fi
source "${my_dir}"/sync.sh
