#!/bin/bash
set -e
set -x
cd $(dirname $0)
cd ..

FLUTTER_ARCH=""
if [[ "$(uname -m)" == "aarch64" ]];
then
    FLUTTER_ARCH="arm64"
fi

flutter-elinux pub get
flutter-elinux build elinux --release

./build_moneroc.sh --prebuild --coin monero --tag ${MONERO_C_TAG} --triplet $(uname -m)-linux-gnu --location $PWD/build/elinux/${FLUTTER_ARCH}/release/bundle/lib/

cp $HOME/SailfishOS/flutter-elinux/$(uname -m)/flutter-client build/elinux/${FLUTTER_ARCH}/release/bundle/flutter-client

cat > build/elinux/${FLUTTER_ARCH}/release/bundle/unnamed_monero_wallet <<EOF
#!/bin/bash
cd \$(dirname \$0)
killall flutter-client || true

LD_PRELOAD=\$PWD/lib/libflutter_engine.so ./flutter-client --bundle=\$PWD --fullscreen --force-scale-factor=3
EOF

chmod +x build/elinux/${FLUTTER_ARCH}/release/bundle/unnamed_monero_wallet

rpmbuild -bb elinux/sailfishos.spec --define "_bundledir $PWD/build/elinux/${FLUTTER_ARCH}/release/bundle/" --define "_sourcedir $PWD"
cp $HOME/rpmbuild/RPMS/$(uname -m)/unnamed-monero-wallet-debuginfo-1.0.0+*.rpm build/elinux/${FLUTTER_ARCH}/release/unnamed-monero-wallet-debuginfo.$(uname -m).rpm
cp $HOME/rpmbuild/RPMS/$(uname -m)/unnamed-monero-wallet-debugsource-1.0.0+*.rpm build/elinux/${FLUTTER_ARCH}/release/unnamed-monero-wallet-debugsource.$(uname -m).rpm
cp $HOME/rpmbuild/RPMS/$(uname -m)/unnamed-monero-wallet-1.0.0+*.rpm build/elinux/${FLUTTER_ARCH}/release/unnamed-monero-wallet.$(uname -m).rpm
