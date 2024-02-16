.PHONY: apk
apk:
	flutter build apk --flavor calc  --dart-define=libstealth_calculator=true
	flutter build apk --flavor clean --dart-define=libstealth_calculator=false

.PHONY: linux
linux: 
	flutter build linux
	echo https://git.mrcyjanek.net/mrcyjanek/monero_c/releases/download/${shell ./get_current_build.sh}/x86_64-linux-gnu_libwallet2_api_c.so.xz
	wget https://git.mrcyjanek.net/mrcyjanek/monero_c/releases/download/v0.18.3.1-RC48/x86_64-linux-gnu_libwallet2_api_c.so.xz \
		-O build/linux/x64/release/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/x64/release/bundle/lib/libwallet2_api_c.so
	unxz build/linux/x64/release/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/x64/release/xmruw-linux-amd64.tar*
	(cd build/linux/x64/release && cp -a bundle xmruw && tar -cvf xmruw-linux-amd64.tar xmruw && xz -e xmruw-linux-amd64.tar)


.PHONY: linux_debug_lib
linux_debug_lib:
	wget https://git.mrcyjanek.net/mrcyjanek/monero_c/releases/download/v0.18.3.1-RC48/x86_64-linux-gnu_libwallet2_api_c.so.xz \
		-O build/linux/x64/debug/bundle/lib/libwallet2_api_c.so.xz
	-rm build/linux/x64/debug/bundle/lib/libwallet2_api_c.so
	unxz build/linux/x64/debug/bundle/lib/libwallet2_api_c.so.xz

deb: linux
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
