#!/bin/bash

# Email for git
GITHUB_USER=Akianonymus
ci_repo=$(cat /drone/src/.git/config | grep url | sed 's|url = https://github.com/||' | sed 's|.git||')
git config --global user.email "anonymus.aki@gmail.com"
git config --global user.name "$GITHUB_USER"

export KBUILD_BUILD_USER="Aki"
export KBUILD_BUILD_HOST="A_DEAD_PLANET"

TELEGRAM_TOKEN=$(cat /tmp/tg_token)
TELEGRAM_CHAT=$(cat /tmp/tg_chat)
GITHUB_TOKEN=$(cat /tmp/gh_token)

export TELEGRAM_TOKEN
export TELEGRAM_CHAT
export GITHUB_TOKEN

function set_device() {
    device="harpia"
    export device="$device"
}

function trim_darwin() {
    cd .repo/manifests
    cat default.xml | grep -v darwin  > temp && cat temp > default.xml && rm temp
    git commit -a -m "Magic"
    cd ../
    cat manifest.xml | grep -v darwin  > temp && cat temp > manifest.xml && rm temp
    cd ../
}

set_device
export ROM="PixelExperience"
manifest_url="https://github.com/PixelExperience/manifest"
export outdir="out/target/product/$device"
export release_repo="Akianonymus/harpia_builds"
export ci_url="$(echo "https://cloud.drone.io/$ci_repo/"$(cat /tmp/build_no)"/1/2" | sed 's| ||')"

cd /home/ci

mkdir $ROM
cd $ROM
repo init -u $manifest_url -b pie --depth 1 > /dev/null 2>&1
echo "Sync started for $manifest_url"
telegram -M "Sync Started for [$ROM]($manifest_url)"
SYNC_START=$(date +"%s")
trim_darwin >  /dev/null 2>&1
repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all) -q 2>&1 >>logwe 2>&1
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ -e frameworks/base ]; then
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    echo "Build Started"
    telegram -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds

Build Started: [See Progress]($ci_url)"

    BUILD_START=$(date +"%s")

    . build/envsetup.sh > /dev/null 2>&1
    set_device
    lunch aosp_$device-userdebug > /dev/null 2>&1
    mka bacon | grep $device
    BUILD_END=$(date +"%s")
    BUILD_DIFF=$((BUILD_END - BUILD_START))

    export finalzip_path=$(ls "$outdir"/*201*.zip | tail -n -1)
    export zip_name=$(echo $finalzip_path | sed "s|$outdir/||")
    export tag=$( echo $zip_name | sed 's|.zip||')
    if [ -e $finalzip_path ]; then
        echo "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"

        echo "Uploading"

        github-release "$release_repo" "$tag" "master" "$ROM for $device

Date: $(env TZ=Asia/Kolkata date)" "$finalzip_path"

        echo "Uploaded"

        telegram -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download: [$zip_name](https/github.com/$release_repo/releases/download/$tag/$zip_name)"

    else
        echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
        telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
        exit 1
    fi
else
    echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    exit 1
fi
