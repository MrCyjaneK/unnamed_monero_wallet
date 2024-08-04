include .env

MONERO_C_TAG=v0.18.3.3-RC51

.PHONY: android
android:
	./build_changelog.sh
	flutter build apk --flavor ${APP_FLAVOR}

.PHONY: linux
linux: 
	./build_changelog.sh
	flutter build linux
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet $(shell gcc -dumpmachine)  --location build/linux/${FLUTTER_ARCH}/release/bundle/lib
	-rm build/linux/${FLUTTER_ARCH}/release/${BINARY_NAME}-linux-${FLUTTER_ARCH}.tar*
	(cd build/linux/${FLUTTER_ARCH}/release && cp -a bundle ${BINARY_NAME} && tar -cvf ${BINARY_NAME}-linux-${COIN}-${FLUTTER_ARCH}.tar ${BINARY_NAME} && xz -e ${BINARY_NAME}-linux-${COIN}-${FLUTTER_ARCH}.tar)


.PHONY: linux_debug_lib
linux_debug_lib:
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet $(shell gcc -dumpmachine)  --location /usr/lib

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
	sed -i "s/^Version=.*/Version=1.0.0+$(shell git rev-list --count HEAD)/" "debian/gui/${BINARY_NAME}.desktop"
	sed -i "s/^Version=.*/Version=1.0.0+$(shell git rev-list --count HEAD)/" "elinux/unnamed-${COIN}-wallet.desktop"
	sed -i "s/^Version:    .*/Version:    1.0.0/" "elinux/sailfishos.spec"
	sed -i "s/^Release:    .*/Release:    $(shell git rev-list --count HEAD)/" "elinux/sailfishos.spec"
	sed -i "s/^Version:    .*/Version:    1.0.0/" "elinux/sailfishos.spec"
	sed -i "s/^const ${BINARY_NAME}Version = .*/const ${BINARY_NAME}Version = '$(shell git describe --tags)';/" "lib/helpers/licenses_extra.dart"

.PHONY: version_nongnu
version_nongnu:
	sed -i '' "s/^version: .*/version: 1.0.0+$(shell git rev-list --count HEAD)/" "pubspec.yaml"
	sed -i '' "s/^  Version: .*/  Version: 1.0.0+$(shell git rev-list --count HEAD)/" "debian/debian.yaml.txt"
	sed -i '' "s/^Version=.*/Version=1.0.0+$(shell git rev-list --count HEAD)/" "debian/gui/${BINARY_NAME}.desktop"
	sed -i '' "s/^Version=.*/Version=1.0.0+$(shell git rev-list --count HEAD)/" "elinux/unnamed-${COIN}-wallet.desktop"
	sed -i '' "s/^Version:    .*/Version:    1.0.0/" "elinux/sailfishos.spec"
	sed -i '' "s/^Release:    .*/Release:    $(shell git rev-list --count HEAD)/" "elinux/sailfishos.spec"
	sed -i '' "s/^Version:    .*/Version:    1.0.0/" "elinux/sailfishos.spec"
	sed -i '' "s/^const ${BINARY_NAME}Version = .*/const ${BINARY_NAME}Version = '$(shell git describe --tags)';/" "lib/helpers/licenses_extra.dart"

.PHONY: lib/helpers/licenses.g.dart
lib/helpers/licenses.g.dart:
	dart run flutter_oss_licenses:generate -o lib/helpers/licenses.g.dart

libs_android_download:
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet arm-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

libs_android_build:
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet arm-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

windows_libs_download:
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-w64-mingw32 --location build/windows/x64/runner/Release

.PHONY: macos_arm64
macos_arm64:
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-darwin11 --location macos
	flutter build macos -v
	test -f build/${BINARY_NAME}_darwin_arm64.dmg && rm -rf build/${BINARY_NAME}_darwin_arm64.dmg || true
	create-dmg \
		--volname "${BINARY_NAME}" \
		--background "assets/macos_installer_background.png" \
		--window-pos 200 120 \
		--window-size 588 440 \
		--icon-size 75 \
		--icon unnamed_${COIN}_wallet.app 134 205 \
		--hide-extension unnamed_${COIN}_wallet.app \
		--app-drop-link 460 205 \
		--eula LICENSE \
		build/${BINARY_NAME}_darwin_arm64.dmg \
		build/macos/Build/Products/Release
