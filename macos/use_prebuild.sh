#!/bin/bash

set -x -e

cd "$(dirname "$0")"

LIB_PATH="$(readlink monero_libwallet2_api_c.dylib)"
LIB_DIR="$(dirname "$LIB_PATH")"

if [[ ! -d "$LIB_DIR" ]];
then
    mkdir -p "$LIB_DIR"
fi


CURRENT_TAG="$(grep "MONERO_C_TAG=" ../Makefile | tr '=' "\n" | tail -1)"

wget https://static.mrcyjanek.net/monero_c/${CURRENT_TAG}/monero/aarch64-apple-darwin11_libwallet2_api_c.dylib.xz -O "$LIB_PATH.xz"
unxz -f ${LIB_PATH}.xz