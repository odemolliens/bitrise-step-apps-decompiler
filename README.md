<img align="right" src="assets/icon.svg" width="150" height="150" >

# Bitrise step - Mobile apps decompiler

This step ecompile mobile APK and/or IPA

This step will get (or download if you launched this step from outside of the Bitrise build where you generate your apk) your APK/IPA and decompile them to:
- apk_decompiled/
- ipa_unzipped/

<br/>

## Usage

Add this step using standard Workflow Editor and provide required input environment variables.

<br/>

You can launch this step:
- directly in the step where you generate your APK/IPA, in that case, you have to launch it necessarily after these build steps
  - `Android Build` for android
  - `Xcode Archive` for iOS
- **OR** in another Bitrise build than where you generate your APK/IPA, in that case, you have to setup `outside_build_slug` to download your APK/IPA to do quality checks

<br/>

## Inputs

The asterisks (*) mean mandatory keys

|Key             |Value type                     |Description    |Default value        
|----------------|-------------|--------------|--------------|
|decompile_android* |yes/no |Setup - Set yes if you want decompile Android APK|yes|
|decompile_ios* |yes/no |Setup - Set yes if you want decompile iOS IPA|yes|
|outside_build_slug |String |Setup - Set the build slug if you exported as an artifact your APK/IPA in another Bitrise build, if you launch this step in the Bitrise build where you generate your APK/IPA, you don't need to setup this key but you have to launch this step after the steps which generate the APK/IPA ||
|android_apk_path | String |Config - File path to APK file to get info from|$BITRISE_APK_PATH|
|ios_ipa_path | String |Config - File path to IPA file to get info from|$BITRISE_IPA_PATH|
