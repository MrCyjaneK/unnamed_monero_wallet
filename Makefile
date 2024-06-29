MONERO_C_TAG=v0.18.3.3-RC47
LIBCPP_SHARED_SO_TAG=latest-RC1
LIBCPP_SHARED_SO_NDKVERSION=r17c

.PHONY: android
android:
	./build_changelog.sh
	flutter build apk --flavor calc  --dart-define=libstealth_calculator=true
	flutter build apk --flavor clean --dart-define=libstealth_calculator=false

.PHONY: linux
linux: 
	./build_changelog.sh
	flutter build linux
	./build_moneroc.sh --prebuild --coin monero --tag ${MONERO_C_TAG} --triplet $(shell gcc -dumpmachine)  --location build/linux/${FLUTTER_ARCH}/release/bundle/lib
	-rm build/linux/${FLUTTER_ARCH}/release/xmruw-linux-${FLUTTER_ARCH}.tar*
	(cd build/linux/${FLUTTER_ARCH}/release && cp -a bundle xmruw && tar -cvf xmruw-linux-${FLUTTER_ARCH}.tar xmruw && xz -e xmruw-linux-${FLUTTER_ARCH}.tar)


.PHONY: linux_debug_lib
linux_debug_lib:
	./build_moneroc.sh --prebuild --coin monero --tag ${MONERO_C_TAG} --triplet x86_64-linux-gnu  --location build/linux/*/debug/bundle/lib

.PHONY: dev
dev: libs

dev:
lib/const/resource.g.dart:
	dart pub global activate flutter_asset_generator
	timeout 15 ${HOME}/.pub-cache/bin/fgen || true
	mv lib/const/resource.dart lib/const/resource.g.dart
.PHONY: lib/const/resource.g.dart

.PHONY: sailfishos
sailfishos:
	./build_changelog.sh
	bash ./elinux/sailfish_build.sh

.PHONY: version
version:
	sed -i "s/^version: .*/version: 1.0.0+$(shell git rev-list --count HEAD)/" "pubspec.yaml"
	sed -i "s/^  Version: .*/  Version: 1.0.0+$(shell git rev-list --count HEAD)/" "debian/debian.yaml.txt"
	sed -i "s/^Version=.*/Version=1.0.0+$(shell git rev-list --count HEAD)/" "debian/gui/xmruw.desktop"
	sed -i "s/^Version=.*/Version=1.0.0+$(shell git rev-list --count HEAD)/" "elinux/unnamed-monero-wallet.desktop"
	sed -i "s/^Version:    .*/Version:    1.0.0/" "elinux/sailfishos.spec"
	sed -i "s/^Release:    .*/Release:    $(shell git rev-list --count HEAD)/" "elinux/sailfishos.spec"
	sed -i "s/^Version:    .*/Version:    1.0.0/" "elinux/sailfishos.spec"
	sed -i "s/^const xmruwVersion = .*/const xmruwVersion = '$(shell git describe --tags)';/" "lib/helpers/licenses_extra.dart"

.PHONY: lib/helpers/licenses.g.dart
lib/helpers/licenses.g.dart:
	dart run flutter_oss_licenses:generate -o lib/helpers/licenses.g.dart

libs_android_download:
	./build_moneroc.sh --prebuild --coin monero --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --prebuild --coin monero --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --prebuild --coin monero --tag ${MONERO_C_TAG} --triplet arm-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

libs_android_build:
	./build_moneroc.sh --coin monero --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --coin monero --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --coin monero --tag ${MONERO_C_TAG} --triplet arm-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

.PHONY: macos
macos:
	# cd macos && ./use_prebuild.sh
	# flutter build macos -v
	test -f build/xmruw.dmg && rm -rf build/xmruw.dmg || true
	create-dmg \
		--volname "xmruw" \
		--background "assets/macos_installer_background.png" \
		--window-pos 200 120 \
		--window-size 588 440 \
		--icon-size 75 \
		--icon unnamed_monero_wallet.app 134 205 \
		--hide-extension unnamed_monero_wallet.app \
		--app-drop-link 460 205 \
		--eula LICENSE \
		build/xmruw.dmg \
		build/macos/Build/Products/Release
