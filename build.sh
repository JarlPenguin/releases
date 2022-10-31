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
source "${my_dir}/config.sh"
if [ -z "${buildtype}" ]; then
    export buildtype="userdebug"
fi
if [ "${ccache}" == "true" ] && [ -n "${ccache_size}" ]; then
    export USE_CCACHE=1
    ccache -M "${ccache_size}G"
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
else
    rm "${outdir}"/*$(date +%Y)*.zip*
fi
m "${bacon}" -j$(nproc --all)
buildsuccessful="${?}"
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))

if [ "${buildsuccessful}" == "0" ] && [ ! -z "${finalzip_path}" ]; then
    echo "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"

    telegram -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"

curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker

else
    echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
    exit 1
fi
