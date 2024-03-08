.PHONY: android
android:
	./build_changelog.sh
	flutter build apk --flavor calc  --dart-define=libstealth_calculator=true
	flutter build apk --flavor clean --dart-define=libstealth_calculator=false

.PHONY: linux
linux: 
	./build_changelog.sh
	flutter build linux
	echo https://static.mrcyjanek.net/monero_c/${shell ./get_current_build.sh}/${TARGET_TRIPLET}_libwallet2_api_c.so.xz
	wget https://static.mrcyjanek.net/monero_c/${shell ./get_current_build.sh}/${TARGET_TRIPLET}_libwallet2_api_c.so.xz \
		-O build/linux/${FLUTTER_ARCH}/release/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/${FLUTTER_ARCH}/release/bundle/lib/libwallet2_api_c.so
	unxz build/linux/${FLUTTER_ARCH}/release/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/${FLUTTER_ARCH}/release/xmruw-linux-${DEBIAN_ARCH}.tar*
	(cd build/linux/${FLUTTER_ARCH}/release && cp -a bundle xmruw && tar -cvf xmruw-linux-${DEBIAN_ARCH}.tar xmruw && xz -e xmruw-linux-${DEBIAN_ARCH}.tar)


.PHONY: linux_debug_lib
linux_debug_lib:
	wget https://static.mrcyjanek.net/monero_c/${shell ./get_current_build.sh}/${shell gcc -dumpmachine}_libwallet2_api_c.so.xz \
		-O build/linux/${FLUTTER_ARCH}/debug/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/${FLUTTER_ARCH}/debug/bundle/lib/libwallet2_api_c.so
	unxz build/linux/${FLUTTER_ARCH}/debug/bundle/lib/libwallet2_api_c.so.xz

deb:
	dart pub global activate --source git https://github.com/tomekit/flutter_to_debian.git
	cat debian/debian.yaml.txt | sed 's/x64/${FLUTTER_ARCH}/g' | sed 's/amd64/${DEBIAN_ARCH}/g' > debian/debian.yaml
	${HOME}/.pub-cache/bin/flutter_to_debian

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
	sed -i "s/^Version:    .*/Version:    1.0.0+$(shell git rev-list --count HEAD)/" "elinux/sailfishos.spec"
	sed -i "s/^Release:    .*/Release:    $(shell git rev-list --count HEAD)/" "elinux/sailfishos.spec"
	sed -i "s/^Version:    .*/Version:    1.0.0+$(shell git rev-list --count HEAD)/" "elinux/sailfishos.spec"
	sed -i "s/^const xmruwVersion = .*/const xmruwVersion = '$(shell git describe --tags)';/" "lib/helpers/licenses_extra.dart"

.PHONY: lib/helpers/licenses.g.dart
lib/helpers/licenses.g.dart:
	dart pub run flutter_oss_licenses:generate.dart -o lib/helpers/licenses.g.dart