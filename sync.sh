#!/bin/bash
echo "Sync started for ${manifest_url}/tree/${branch}"
if [ "${jenkins}" == "true" ]; then
    ${my_dir}/bin/telegram -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url}/tree/${branch}): [See Progress](${BUILD_URL}console)"
else
    ${my_dir}/bin/telegram -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url}/tree/${branch})"
fi
SYNC_START=$(date +"%s")
rm -rf .repo/local_manifests
mkdir -p .repo/local_manifests
wget "${local_manifest_url}" -O .repo/local_manifests/manifest.xml
${my_dir}/bin/repo init -u "${manifest_url}" -b "${branch}" --depth 1
cores=$(nproc --all)
if [ "${cores}" -gt "8" ]; then
    cores=8
fi
${my_dir}/bin/repo sync --force-sync --fail-fast --no-tags --no-clone-bundle --optimized-fetch --prune "-j${cores}" -c -v
syncsuccessful="${?}"
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ "${syncsuccessful}" == "0" ]; then
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    ${my_dir}/bin/telegram -N -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    source "${my_dir}/build.sh"
else
    echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    ${my_dir}/bin/telegram -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
    exit 1
fi
