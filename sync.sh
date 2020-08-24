#!/bin/bash
echo "Sync started for ${manifest_url}/tree/${branch}"
if [ "${jenkins}" == "true" ]; then
    telegram -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url}/tree/${branch}): [See Progress](${BUILD_URL}console)"
else
    telegram -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url}/tree/${branch})"
fi
SYNC_START=$(date +"%s")
if [ "${official}" != "true" ]; then
    mkdir -p .repo/local_manifests
    if [ -f .repo/local_manifests/manifest.xml ]; then
        rm .repo/local_manifests/manifest.xml
    fi
    wget "${local_manifest_url}" -O .repo/local_manifests/manifest.xml
fi
cores=$(nproc --all)
if [ "${cores}" -gt "12" ]; then
    cores=12
fi
repo sync --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune "-j${cores}" -c -v
syncsuccessful="${?}"
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ "${syncsuccessful}" == "0" ]; then
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    source "${my_dir}/build.sh"
else
    echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
    exit 1
fi
