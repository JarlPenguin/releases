#!/bin/bash
echo "Sync started for ${manifest_url}/tree/${branch}"
telegram -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url}/tree/${branch})"
SYNC_START=$(date +"%s")
if [ "${local_manifest_url}" == *.xml* ]; then
    localmanifestisrepo=false
fi
if [ "${official}" != "true" ]; then
    if [ "${localmanifestisrepo}" == "false" ]; then
        mkdir -p .repo/local_manifests
        if [ -f .repo/local_manifests/manifest.xml ]; then
            rm .repo/local_manifests/manifest.xml
        fi
        wget "${local_manifest_url}" -O .repo/local_manifests/manifest.xml
    else
        rm -r .repo/local_manifests
        git clone "${local_manifest_url}" --depth 1 .repo/local_manifests
    fi
fi
repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all) -c
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
