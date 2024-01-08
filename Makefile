.PHONY: apk
apk:
	flutter build apk --flavor anon
	flutter build apk --flavor nero

.PHONY: linux
linux:
	flutter build linux
	(cd build/linux/x64/release && cp -a bundle anonero && tar -cvf anonero-linux-amd64.tar anonero)

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
	sed -i "s/^Version=.*/Version=1.0.0+$(shell git rev-list --count HEAD)/" "debian/gui/anonero.desktop"
