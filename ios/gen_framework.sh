#!/bin/sh
# Assume we are in scripts/ios
cd "$(dirname "$0")"
IOS_DIR="$(pwd)"
DYLIB_NAME="monero_libwallet2_api_c.dylib"
DYLIB_LINK_PATH="${IOS_DIR}/${DYLIB_NAME}"
FRWK_DIR="${IOS_DIR}/MoneroWallet.framework"

if [ ! -f $DYLIB_LINK_PATH ]; then
    echo "Dylib is not found by the link: ${DYLIB_LINK_PATH}"
    exit 0
fi

cd $FRWK_DIR # go to iOS framework dir
lipo -create $DYLIB_LINK_PATH -output MoneroWallet
