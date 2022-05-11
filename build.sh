#!/bin/bash

# Inherit configuration
source config.sh
source secrets.sh
scripts_directory=$(pwd)
out="${rom_directory}"/out/target/product/"${device_codename}"
TELEGRAM_CHAT="${user_telegram_chat_id}"
TELEGRAM_TOKEN="${user_telegram_bot_token}"

# Enter ROM directory
cd "${rom_directory}"

# Send start messages
start=$(date +"%s")
echo "Build started for ${device_codename}"
if [ "${build_jenkins}" == "true" ]; then
    telegram -M "Build ${BUILD_DISPLAY_NAME} started for ${device_codename}: [See Progress](${BUILD_URL}console)"
else
    telegram -M "Build started for ${device_codename}"
fi

# Setup build environment
source build/envsetup.sh
if [ "${build_ccache}" == "true" ] && [ -n "${build_ccache_size}" ]; then
    export USE_CCACHE=1
    ccache -M "${build_ccache_size}"
elif [ "${build_ccache}" == "true" ] && [ -z "${build_ccache_size}" ]; then
    echo "Please set the build_ccache_size variable in your config."
    exit 1
fi
if [ ! -z "${rom_prefix}" ]; then
    lunch "${rom_prefix}_${device_codename}-${build_type}"
else
    lunch "${device_codename}-${build_type}"
fi

# Clean out directory if needed
if [ "${build_clean}" == "clean" ]; then
    m clean -j$(nproc --all)
elif [ "${build_clean}" == "installclean" ]; then
    m installclean -j$(nproc --all)
    rm -rf "${out}"/obj/DTBO_OBJ
fi
rm "${out}"/*.*

# Build the target
m "${build_target}" -j$(nproc --all)
successful="${?}"

# Generate incremental update
if [ "${build_incremental}" == "true" ]; then
    if [ -e "${rom_directory}"/*"${device_codename}"*target_files*.zip ]; then
        old_target_files=true
        old_target_files_path=$(ls "${rom_directory}"/*"${device_codename}"*target_files*.zip | tail -n -1)
    else
        echo "Old target files package not found. Generating incremental package on next build."
    fi
    export new_target_files_path=$(ls "${out}"/obj/PACKAGING/target_files_intermediates/*target_files*.zip | tail -n -1)
    if [ "${old_target_files}" == "true" ]; then
        ota_from_target_files -i "${old_target_files_path}" "${new_target_files_path}" "${out}"/incremental_ota_update.zip
        successful="${?}"
    fi
    cp "${new_target_files_path}" "${rom_directory}"
fi

# Send end messages
end=$(date +"%s")
difference=$((end - start))
if [ "${successful}" == "0" ]; then
    echo "Build completed successfully in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
    telegram -N -M "Build completed successfully in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
else
    echo "Build failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
    telegram -N -M "Build failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id="${user_telegram_chat_id}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${user_telegram_bot_token}"/sendSticker
    exit 1
fi

# Go back to start directory
cd "${scripts_directory}"
