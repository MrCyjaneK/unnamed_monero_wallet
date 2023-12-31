MONERO_C_TAG=v0.18.3.1-RC26
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


.PHONY: version
version:
	sed -i "s/^version: .*/version: 0.0.1+$(shell git rev-list --count HEAD)/" "pubspec.yaml"