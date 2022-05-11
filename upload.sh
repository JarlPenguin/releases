#!/bin/bash

# Inherit configuration
source config.sh
source secrets.sh
GITHUB_TOKEN="${user_github_token}"
out="${rom_directory}"/out/target/product/"${device_codename}"
TELEGRAM_CHAT="${user_telegram_chat_id}"
TELEGRAM_TOKEN="${user_telegram_bot_token}"

# Send start messages
start=$(date +"%s")
echo "Uploading build artifacts..."
telegram -M "Uploading build artifacts..."

incremental_path=$(ls "${out}"/incremental_ota_update.zip | tail -n -1)
full_path=$(ls "${out}"/*"${device_codename}"-ota-*.zip | tail -n -1)
if [ "${upload_recovery}" == "true" ]; then
    if [ -e "${out}"/recovery.img ]; then
        recovery_path=$(ls "${out}"/recovery.img | tail -n -1)
    else
        recovery_path=$(ls "${out}"/boot.img | tail -n -1)
    fi
fi
full_name=$(echo "${full_path}" | sed "s|${out}/||")
tag=$(echo "$(date +%Y%m%d%H%M)-${full_name}" | sed 's|.zip||')
if [ ! -z "${full_path}" ]; then
    github-release "${release_repo}" "${tag}" "master" "${ROM} for ${device_codename}

Date: $(env TZ="${timezone}" date)" "${full_path}"
    if [ "${generate_incremental}" == "true" ]; then
        if [ -e "${incremental_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            github-release "${release_repo}" "${tag}" "master" "${ROM} for ${device_codename}

Date: $(env TZ="${timezone}" date)" "${incremental_path}"
        elif [ ! -e "${incremental_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            echo "Build failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
            telegram -N -M "Build failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
            curl --data parse_mode=HTML --data chat_id="${user_telegram_chat_id}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${user_telegram_bot_token}"/sendSticker
            exit 1
        fi
    fi
    if [ "${upload_recovery}" == "true" ]; then
        if [ -e "${recovery_path}" ]; then
            github-release "${release_repo}" "${tag}" "master" "${ROM} for ${device_codename}

Date: $(env TZ="${timezone}" date)" "${recovery_path}"
        else
            echo "Build failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
            telegram -N -M "Build failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
            curl --data parse_mode=HTML --data chat_id="${user_telegram_chat_id}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${user_telegram_bot_token}"/sendSticker
            exit 1
        fi
    fi
    echo "Uploaded"

    if [ "${upload_recovery}" == "true" ]; then
        if [ "${old_target_files_exists}" == "true" ]; then
            telegram -M "Build completed successfully in $((difference / 60)) minute(s) and $((difference % 60)) seconds

Download ROM: ["${full_name}"]("https://github.com/${release_repo}/releases/download/${tag}/${full_name}")
Download incremental update: ["incremental_ota_update.zip"]("https://github.com/${release_repo}/releases/download/${tag}/incremental_ota_update.zip")
Download recovery: ["recovery.img"]("https://github.com/${release_repo}/releases/download/${tag}/recovery.img")"
        else
            telegram -M "Build completed successfully in $((difference / 60)) minute(s) and $((difference % 60)) seconds

Download ROM: ["${full_name}"]("https://github.com/${release_repo}/releases/download/${tag}/${full_name}")
Download recovery: ["recovery.img"]("https://github.com/${release_repo}/releases/download/${tag}/recovery.img")"
        fi
    else
        if [ "${old_target_files_exists}" == "true" ]; then
            telegram -M "Build completed successfully in $((difference / 60)) minute(s) and $((difference % 60)) seconds

Download: ["${full_name}"]("https://github.com/${release_repo}/releases/download/${tag}/${full_name}")
Download incremental update: ["incremental_ota_update.zip"]("https://github.com/${release_repo}/releases/download/${tag}/incremental_ota_update.zip")"
        else
            telegram -M "Build completed successfully in $((difference / 60)) minute(s) and $((difference % 60)) seconds

Download: ["${full_name}"]("https://github.com/${release_repo}/releases/download/${tag}/${full_name}")"
        fi
    fi
curl --data parse_mode=HTML --data chat_id="${user_telegram_chat_id}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${user_telegram_bot_token}"/sendSticker


if [ "${successful}" == "0" ]; then
else
    echo "Upload failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
    telegram -N -M "Upload failed in $((difference / 60)) minute(s) and $((difference % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id="${user_telegram_chat_id}" --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot"${user_telegram_bot_token}"/sendSticker
    exit 1
fi
