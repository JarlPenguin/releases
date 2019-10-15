#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}"/config.sh

if [ "${GITHUB_TOKEN}" == "" ] || [ "${TELEGRAM_CHAT}" == "" ] || [ "${TELEGRAM_TOKEN}" == "" ]; then
    echo "Please set GITHUB_TOKEN, TELEGRAM_CHAT, and TELEGRAM_TOKEN before continuing."
    exit 1
fi

# Email for git
git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"

function trim_darwin() {
    cd .repo/manifests
    cat default.xml | grep -v darwin  > temp && cat temp > default.xml && rm temp
    git commit -a -m "Magic"
    cd ../
    cat manifest.xml | grep -v darwin  > temp && cat temp > manifest.xml && rm temp
    cd ../
}

cd ~

if [ ! -d "${ROM_DIR}" ]; then
mkdir "${ROM_DIR}"
fi
cd "${ROM_DIR}"
if [ -d "${ROM_DIR}/out" ]; then
make clean -j$(nproc --all)
make clobber -j$(nproc --all)
fi

if [ ! -d "${ROM_DIR}/.repo" ]; then
echo "Initializing repository..."
repo init -u "${manifest_url}" -b "${branch}" --depth 1
trim_darwin
fi
source "${my_dir}"/sync.sh
