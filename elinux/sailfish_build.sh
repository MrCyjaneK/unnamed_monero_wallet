#!/bin/bash
set -e
set -x
cd $(dirname $0)
cd ..
source .env
MONERO_C_TAG=$(cat Makefile | grep 'MONERO_C_TAG=' | tr '=' ' ' | awk '{ print $2 }')
FLUTTER_ARCH=""
if [[ "$(uname -m)" == "aarch64" ]];
then
    FLUTTER_ARCH="arm64"
fi

flutter-elinux pub get
flutter-elinux build elinux --release

./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet $(uname -m)-meego-linux-gnu --location $PWD/build/elinux/${FLUTTER_ARCH}/release/bundle/lib/

cp $HOME/SailfishOS/flutter-elinux/$(uname -m)/flutter-client build/elinux/${FLUTTER_ARCH}/release/bundle/flutter-client

cat > build/elinux/${FLUTTER_ARCH}/release/bundle/unnamed_${COIN}_wallet <<EOF
#!/bin/bash
cd \$(dirname \$0)
killall flutter-client || true

LD_PRELOAD=\$PWD/lib/libflutter_engine.so ./flutter-client --bundle=\$PWD --fullscreen --force-scale-factor=3
EOF

chmod +x build/elinux/${FLUTTER_ARCH}/release/bundle/unnamed_${COIN}_wallet

rpmbuild -bb elinux/sailfishos.spec --define "_bundledir $PWD/build/elinux/${FLUTTER_ARCH}/release/bundle/" --define "_sourcedir $PWD"
cp $HOME/rpmbuild/RPMS/$(uname -m)/unnamed-${COIN}-wallet-debuginfo-1.0.0*.rpm build/elinux/${FLUTTER_ARCH}/release/unnamed-${COIN}-wallet-debuginfo.$(uname -m).rpm
cp $HOME/rpmbuild/RPMS/$(uname -m)/unnamed-${COIN}-wallet-debugsource-1.0.0*.rpm build/elinux/${FLUTTER_ARCH}/release/unnamed-${COIN}-wallet-debugsource.$(uname -m).rpm
cp $HOME/rpmbuild/RPMS/$(uname -m)/unnamed-${COIN}-wallet-1.0.0*.rpm build/elinux/${FLUTTER_ARCH}/release/unnamed-${COIN}-wallet.$(uname -m).rpm
