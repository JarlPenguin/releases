#!/bin/bash

# Inherit configuration
source config.sh
source secrets.sh
scripts_directory=$(pwd)
TELEGRAM_CHAT="${user_telegram_chat_id}"
TELEGRAM_TOKEN="${user_telegram_bot_token}"

# Setup Git
git config --global user.email "${user_github_email}"
git config --global user.name "${user_github_username}"

# Enter ROM directory
mkdir -p "${rom_directory}"
cd "${rom_directory}"

# Send start messages
echo "Sync started for ${rom_manifest}"
if [ "${build_jenkins}" == "true" ]; then
    telegram -M "Sync started for [${rom} ${rom_version}](${rom_manifest}): [See Progress](${BUILD_URL}console)"
else
    telegram -M "Sync started for [${rom} ${rom_version}](${rom_manifest})"
fi
start=$(date +"%s")

# Download device manifest
mkdir -p .repo/local_manifests
rm -f .repo/local_manifests/*
wget "${device_manifest}" -O .repo/local_manifests/manifest.xml

# Initialize source
repo init -u "${rom_manifest}" -b "${rom_branch}" --depth 1

# Sync source
cores=$(nproc --all)
if [ "${cores}" -gt "8" ]; then
    cores=8
fi
repo sync -c --fail-fast --force-sync "-j${cores}" --no-clone-bundle --no-tags --optimized-fetch --prune -v

# Send end messages
successful="${?}"
end=$(date +"%s")
difference=$((end - start))
if [ "${successful}" == "0" ]; then
    echo "Sync completed successfully in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
    telegram -N -M "Sync completed successfully in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
else
    echo "Sync failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
    telegram -N -M "Sync failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id="${user_telegram_chat_id}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${user_telegram_bot_token}"/sendSticker
    exit 1
fi

# Go back to start directory
cd "${scripts_directory}"
