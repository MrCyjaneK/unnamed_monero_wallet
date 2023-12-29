MONERO_C_TAG=v0.18.3.1-RC11
LIBCPP_SHARED_SO_TAG=latest-RC1
LIBCPP_SHARED_SO_NDKVERSION=r17c


dev: libs
.PHONY: dev

dev:
lib/const/resource.g.dart:
	dart pub global activate flutter_asset_generator
	timeout 15 ${HOME}/.pub-cache/bin/fgen || true
	mv lib/const/resource.dart lib/const/resource.g.dart
.PHONY: lib/const/resource.g.dart

libs: android/app/src/main/jniLibs/arm64-v8a/libwallet2_api_c.so
.PHONY: android/app/src/main/jniLibs/arm64-v8a/libwallet2_api_c.so
android/app/src/main/jniLibs/arm64-v8a/libwallet2_api_c.so:
	wget -q https://git.mrcyjanek.net/mrcyjanek/monero_c/releases/download/${MONERO_C_TAG}/aarch64-linux-android_libwallet2_api_c.so -O android/app/src/main/jniLibs/arm64-v8a/libwallet2_api_c.so

libs: android/app/src/main/jniLibs/arm64-v8a/libc++_shared.so
.PHONY: android/app/src/main/jniLibs/arm64-v8a/libc++_shared.so
android/app/src/main/jniLibs/arm64-v8a/libc++_shared.so:
	wget -q https://git.mrcyjanek.net/mrcyjanek/libcpp_shared.so/releases/download/${LIBCPP_SHARED_SO_TAG}/${LIBCPP_SHARED_SO_NDKVERSION}_arm64-v8a_libc++_shared.so -O android/app/src/main/jniLibs/arm64-v8a/libc++_shared.so

libs: android/app/src/main/jniLibs/armeabi-v7a/libwallet2_api_c.so
.PHONY: android/app/src/main/jniLibs/armeabi-v7a/libwallet2_api_c.so
android/app/src/main/jniLibs/armeabi-v7a/libwallet2_api_c.so:
	wget -q https://git.mrcyjanek.net/mrcyjanek/monero_c/releases/download/${MONERO_C_TAG}/arm-linux-androideabi_libwallet2_api_c.so -O android/app/src/main/jniLibs/armeabi-v7a/libwallet2_api_c.so

libs: android/app/src/main/jniLibs/armeabi-v7a/libc++_shared.so
.PHONY: android/app/src/main/jniLibs/armeabi-v7a/libc++_shared.so
android/app/src/main/jniLibs/armeabi-v7a/libc++_shared.so:
	wget -q https://git.mrcyjanek.net/mrcyjanek/libcpp_shared.so/releases/download/${LIBCPP_SHARED_SO_TAG}/${LIBCPP_SHARED_SO_NDKVERSION}_armeabi-v7a_libc++_shared.so -O android/app/src/main/jniLibs/armeabi-v7a/libc++_shared.so

libs: android/app/src/main/jniLibs/x86/libwallet2_api_c.so
.PHONY: android/app/src/main/jniLibs/x86/libwallet2_api_c.so
android/app/src/main/jniLibs/x86/libwallet2_api_c.so:
	wget -q https://git.mrcyjanek.net/mrcyjanek/monero_c/releases/download/${MONERO_C_TAG}/i686-linux-android_libwallet2_api_c.so -O android/app/src/main/jniLibs/x86/libwallet2_api_c.so

libs: android/app/src/main/jniLibs/x86/libc++_shared.so
.PHONY: android/app/src/main/jniLibs/x86/libc++_shared.so
android/app/src/main/jniLibs/x86/libc++_shared.so:
	wget -q https://git.mrcyjanek.net/mrcyjanek/libcpp_shared.so/releases/download/${LIBCPP_SHARED_SO_TAG}/${LIBCPP_SHARED_SO_NDKVERSION}_x86_libc++_shared.so -O android/app/src/main/jniLibs/x86/libc++_shared.so

libs: android/app/src/main/jniLibs/x86_64/libwallet2_api_c.so
.PHONY: android/app/src/main/jniLibs/x86_64/libwallet2_api_c.so
android/app/src/main/jniLibs/x86_64/libwallet2_api_c.so:
	wget -q https://git.mrcyjanek.net/mrcyjanek/monero_c/releases/download/${MONERO_C_TAG}/x86_64-linux-android_libwallet2_api_c.so -O android/app/src/main/jniLibs/x86_64/libwallet2_api_c.so

libs: android/app/src/main/jniLibs/x86_64/libc++_shared.so
.PHONY: android/app/src/main/jniLibs/x86_64/libc++_shared.so
android/app/src/main/jniLibs/x86_64/libc++_shared.so:
	wget -q https://git.mrcyjanek.net/mrcyjanek/libcpp_shared.so/releases/download/${LIBCPP_SHARED_SO_TAG}/${LIBCPP_SHARED_SO_NDKVERSION}_x86_64_libc++_shared.so -O android/app/src/main/jniLibs/x86_64/libc++_shared.so

.PHONY: version
version:
	sed -i "s/^version: .*/version: 0.0.1+$(shell git rev-list --count HEAD)/" "pubspec.yaml"