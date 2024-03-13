#!/bin/bash
set -e
set -x
export ANDROID_SDK_TOOLS_VERSION=8092744

if [[ -d "$ANDROID_HOME" ]];
then
    echo "$ANDROID_HOME exists, checking if it works"
    (yes | sdkmanager --licenses) && exit 0
    echo "nope. installing anyway."
fi
export PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator:${PATH}"
mkdir -p $ANDROID_HOME
cd $ANDROID_HOME
wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O android-sdk-tools.zip
mkdir -p ${ANDROID_HOME}/cmdline-tools/
unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/
mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest
chown -R root:root $ANDROID_HOME
rm android-sdk-tools.zip

flutter config --android-sdk $ANDROID_HOME

yes | sdkmanager --licenses
sdkmanager platform-tools

rm -rf /opt/android-sdk-linux