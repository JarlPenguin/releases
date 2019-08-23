#!/bin/bash
echo "Sync started for "$manifest_url"/tree/"$branch""
telegram -M "Sync started for ["$ROM" "$ROM_VERSION"]("$manifest_url"/tree/"$branch")"
SYNC_START=$(date +"%s")
if [ "$official" != "true" ] && [ "$official" != "1" ]; then
mkdir -p .repo/local_manifests
if [ -f .repo/local_manifests/manifest.xml ]; then
rm .repo/local_manifests/manifest.xml
fi
wget "$local_manifest_url" -O .repo/local_manifests/manifest.xml
fi
repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all) -c
export synccompletedsuccessfully=$?
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ "$synccompletedsuccessfully" != "0" ]; then
    echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    exit 1
else
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    source "$my_dir"/build.sh
fi
