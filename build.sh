#!/bin/bash

export outdir="${ROM_DIR}/out/target/product/${device}"
BUILD_START=$(date +"%s")
echo "Build started for ${device}"
if [ "${jenkins}" == "true" ]; then
    telegram -M "Build ${BUILD_DISPLAY_NAME} started for ${device}: [See Progress](${BUILD_URL}console)"
else
    telegram -M "Build started for ${device}"
fi
source build/envsetup.sh
repopick -f 325048
source "${my_dir}/config.sh"
if [ -z "${buildtype}" ]; then
    export buildtype="userdebug"
fi
if [ "${ccache}" == "true" ] && [ -n "${ccache_size}" ]; then
    export USE_CCACHE=1
    ccache -M "${ccache_size}G"
    export CCACHE_DIR="/mnt/ccache"
elif [ "${ccache}" == "true" ] && [ -z "${ccache_size}" ]; then
    echo "Please set the ccache_size variable in your config."
    exit 1
else
  unset USE_CCACHE
  unset CCACHE_DIR
  unset CCACHE_EXEC
fi
if [ ! -z "${rom_vendor_name}" ]; then
    lunch "${rom_vendor_name}_${device}-${buildtype}"
else
    lunch "${device}-${buildtype}"
fi
if [ "${clean}" == "clean" ]; then
    m clean -j$(nproc --all)
elif [ "${clean}" == "installclean" ]; then
    m installclean -j$(nproc --all)
    rm -rf out/target/product/"${device}"/obj/DTBO_OBJ
fi
rm -f "${outdir}"/*.zip*
m "${bacon}" -j$(nproc --all)
buildsuccessful="${?}"
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))

if [ "${generate_incremental}" == "true" ]; then
    if [ -e "${my_dir}"/*"${device}"*target_files*.zip ]; then
        export old_target_files_exists=true
        export old_target_files_path=$(ls "${my_dir}"/*"${device}"*target_files*.zip | tail -n -1)
    else
        echo "Old target-files package not found, generating incremental package on next build"
    fi
    export new_target_files_path=$(ls "${outdir}"/obj/PACKAGING/target_files_intermediates/*target_files*.zip | tail -n -1)
    if [ "${old_target_files_exists}" == "true" ]; then
        ota_from_target_files -i "${old_target_files_path}" "${new_target_files_path}" "${outdir}"/incremental_ota_update.zip
        export incremental_zip_path=$(ls "${outdir}"/incremental_ota_update.zip | tail -n -1)
    fi
    cp "${new_target_files_path}" "${my_dir}"
fi
if [ -e "${outdir}"/*$(date +%Y)*.zip ]; then
    export finalzip_path=$(ls "${outdir}"/*$(date +%Y)*.zip | tail -n -1)
else
    export finalzip_path=$(ls "${outdir}"/*"${device}"-ota-*.zip | tail -n -1)
fi
if [ "${upload_recovery}" == "true" ]; then
    if [ ! -e "${outdir}"/recovery.img ]; then
        cp "${outdir}"/boot.img "${outdir}"/recovery.img
    fi
    export img_path=$(ls "${outdir}"/recovery.img | tail -n -1)
fi
export zip_name=$(echo "${finalzip_path}" | sed "s|${outdir}/||")
export tag=$( echo "$(env TZ="${timezone}" date +%Y%m%d%H%M)-${zip_name}" | sed 's|.zip||')
if [ "${buildsuccessful}" == "0" ] && [ ! -z "${finalzip_path}" ]; then
    size=$(du -BG ${finalzip_path} | cut -dG -f1)
    [ "${size}" -ge 2 ] && split ${finalzip_path} ${finalzip_path} -C 2GB && rm ${finalzip_path}

    echo "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"

    echo "Uploading"

    github-release "${release_repo}" "${tag}" "main" "${ROM} for ${device}

Date: $(env TZ="${timezone}" date)" "${finalzip_path}*"
    if [ "${generate_incremental}" == "true" ]; then
        if [ -e "${incremental_zip_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            github-release "${release_repo}" "${tag}" "main" "${ROM} for ${device}

Date: $(env TZ="${timezone}" date)" "${incremental_zip_path}"
        elif [ ! -e "${incremental_zip_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
            exit 1
        fi
    fi
    if [ "${upload_recovery}" == "true" ]; then
        if [ -e "${img_path}" ]; then
            github-release "${release_repo}" "${tag}" "main" "${ROM} for ${device}

Date: $(env TZ="${timezone}" date)" "${img_path}"
        else
            echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
            exit 1
        fi
    fi
    echo "Uploaded"

    telegram -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download: ["${tag}"]("https://github.com/${release_repo}/releases/tag/${tag}")"

    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker

else
    echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
    exit 1
fi
