.PHONY: apk
apk:
	./build_changelog.sh
	flutter build apk --flavor calc  --dart-define=libstealth_calculator=true
	flutter build apk --flavor clean --dart-define=libstealth_calculator=false

.PHONY: linux
linux: 
	./build_changelog.sh
	flutter build linux
	echo https://static.mrcyjanek.net/monero_c/${shell ./get_current_build.sh}/${TARGET_TRIPLET}_libwallet2_api_c.so.xz
	wget https://static.mrcyjanek.net/monero_c/${shell ./get_current_build.sh}/${TARGET_TRIPLET}_libwallet2_api_c.so.xz \
		-O build/linux/x64/release/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/x64/release/bundle/lib/libwallet2_api_c.so
	unxz build/linux/x64/release/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/x64/release/xmruw-linux-amd64.tar*
	(cd build/linux/x64/release && cp -a bundle xmruw && tar -cvf xmruw-linux-amd64.tar xmruw && xz -e xmruw-linux-amd64.tar)


.PHONY: linux_debug_lib
linux_debug_lib:
	wget https://static.mrcyjanek.net/monero_c/${shell ./get_current_build.sh}/${shell gcc -dumpmachine}_libwallet2_api_c.so.xz \
		-O build/linux/x64/debug/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/x64/debug/bundle/lib/libwallet2_api_c.so
	unxz build/linux/x64/debug/bundle/lib/libwallet2_api_c.so.xz

deb:
	dart pub global activate --source git https://github.com/tomekit/flutter_to_debian.git
	${HOME}/.pub-cache/bin/flutter_to_debian

.PHONY: dev
dev: libs

dev:
lib/const/resource.g.dart:
	dart pub global activate flutter_asset_generator
	timeout 15 ${HOME}/.pub-cache/bin/fgen || true
	mv lib/const/resource.dart lib/const/resource.g.dart
.PHONY: lib/const/resource.g.dart


.PHONY: version
version:
	sed -i "s/^version: .*/version: 1.0.0+$(shell git rev-list --count HEAD)/" "pubspec.yaml"
	sed -i "s/^  Version: .*/  Version: 1.0.0+$(shell git rev-list --count HEAD)/" "debian/debian.yaml"
	sed -i "s/^Version=.*/Version=1.0.0+$(shell git rev-list --count HEAD)/" "debian/gui/xmruw.desktop"