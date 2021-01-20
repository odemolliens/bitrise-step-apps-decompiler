#!/bin/bash
set -ex

if [[ ${decompile_android} == "no" && ${decompile_ios} == "no" ]]; then
    echo "Error: You turned off iOS and Android so don't have anything to do"
    exit 1
fi

# dl artifacts list
if [[ ${outside_build_slug} != ""  ]]; then
    BUILD_ARTIFACTS=$(curl -X GET "https://api.bitrise.io/v0.1/apps/${BITRISE_APP_SLUG}/builds/${outside_build_slug}/artifacts" -H "accept: application/json" -H "Authorization: ${BITRISE_TOKEN}")
fi

if [[ ${decompile_android} == "yes" ]]; then
    if [[ ${outside_build_slug} != ""  ]]; then
        # we will download the apk from artifacts
        # dl android artifact
        ANDROID_DATA_FROM_ARTIFACTS=$(echo $BUILD_ARTIFACTS | jq '.data[] | select (.artifact_type == "android-apk")')

        if [[ ${ANDROID_DATA_FROM_ARTIFACTS} == "" ]]; then
            echo "ERROR: Didn't find any apk file in your main build with slug: $outside_build_slug"
            exit 1
        fi

        ANDROID_DATA_SLUG=$(echo $ANDROID_DATA_FROM_ARTIFACTS | jq '.slug' | sed 's/"//g')
        ANDROID_APK_URL=$(curl -X GET "https://api.bitrise.io/v0.1/apps/${BITRISE_APP_SLUG}/builds/${outside_build_slug}/artifacts/${ANDROID_DATA_SLUG}" -H "accept: application/json" -H "Authorization: ${BITRISE_TOKEN}" | jq '.data.expiring_download_url' | sed 's/"//g')

        # download android apk
        curl -X GET ${ANDROID_APK_URL} -o android.apk
    else
        # we will decompile the apk from android_apk_path
        if [[ ${android_apk_path} == "" ]]; then
            echo "ERROR: Didn't find any apk file, please check android apk path android_apk_path=$android_apk_path"
            exit 1
        fi
        
        cp "$android_apk_path" android.apk
    fi

    if [ ! -f "android.apk" ]; then
        echo "ERROR: Cannot find any ipa"
        exit 1
    fi

    # decompile the apk
    apktool d android.apk -o apk_decompiled
    echo "SUCCESS: Android apk decompiled successfully"
fi

if [[ ${decompile_ios} == "yes" ]]; then
    if [[ ${outside_build_slug} != ""  ]]; then
        # we will download the ipa from artifacts
        # dl ios artifact
        IOS_DATA_FROM_ARTIFACTS=$(echo $BUILD_ARTIFACTS | jq '.data[] | select (.artifact_type == "ios-ipa")')

        if [[ ${IOS_DATA_FROM_ARTIFACTS} == "" ]]; then
            echo "ERROR: Didn't find any ipa file in your main build with slug: $outside_build_slug"
            exit 1
        fi

        IOS_DATA_SLUG=$(echo $IOS_DATA_FROM_ARTIFACTS | jq '.slug' | sed 's/"//g')
        IOS_IPA_URL=$(curl -X GET "https://api.bitrise.io/v0.1/apps/${BITRISE_APP_SLUG}/builds/${outside_build_slug}/artifacts/${IOS_DATA_SLUG}" -H "accept: application/json" -H "Authorization: ${BITRISE_TOKEN}" | jq '.data.expiring_download_url' | sed 's/"//g')

        # dl ios ipa
        curl -X GET ${IOS_IPA_URL} -o ios.ipa
    else
        # we will decompile the ipa from ios_ipa_path
        if [[ ${ios_ipa_path} == "" ]]; then
            echo "ERROR: Didn't find any apk file, please check ios ipa path (ios_ipa_path=$ios_ipa_path)"
            exit 1
        fi

        cp "$ios_ipa_path" ios.ipa
    fi

    if [ ! -f "ios.ipa" ]; then
        echo "ERROR: Cannot find any ipa"
        exit 1
    fi

    # decompile the ipa
    mkdir ios_unzipped
    unzip ios.ipa
    mv Payload ios_unzipped/
    echo "SUCCESS: iOS ipa decompiled successfully"
fi

exit 0