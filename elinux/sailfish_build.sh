#!/bin/bash
set -x
cd $(dirname $0)
cd ..

flutter-elinux pub get
flutter-elinux build elinux --release 
curl https://static.mrcyjanek.net/monero_c/$(grep MONERO_C_TAG Makefile | head -1 | tr = ' ' | awk '{ print $2 }')/aarch64-linux-gnu_libwallet2_api_c.so.xz --output $PWD/build/elinux/arm64/release/bundle/lib/libwallet2_api_c.so.xz
unxz $PWD/build/elinux/arm64/release/bundle/lib/libwallet2_api_c.so.xz
cp $HOME/SailfishOS/flutter-elinux/$(uname -m)/flutter-client build/elinux/arm64/release/bundle/flutter-client

cat > build/elinux/arm64/release/bundle/unnamed_monero_wallet <<EOF
#!/bin/bash
cd \$(dirname \$0)
killall flutter-client || true

LD_PRELOAD=\$PWD/lib/libflutter_engine.so ./flutter-client --bundle=\$PWD --fullscreen --force-scale-factor=3
EOF
chmod +x build/elinux/arm64/release/bundle/unnamed_monero_wallet

rpmbuild -bb elinux/sailfishos.spec --define "_bundledir $PWD/build/elinux/arm64/release/bundle/" --define "_sourcedir $PWD"
cp $HOME/rpmbuild/RPMS/aarch64/unnamed-monero-wallet-debuginfo-1.0.0+*.rpm build/elinux/arm64/release/unnamed-monero-wallet-debuginfo.aarch64.rpm
cp $HOME/rpmbuild/RPMS/aarch64/unnamed-monero-wallet-debugsource-1.0.0+*.rpm build/elinux/arm64/release/unnamed-monero-wallet-debugsource.aarch64.rpm
cp $HOME/rpmbuild/RPMS/aarch64/unnamed-monero-wallet-1.0.0+*.rpm build/elinux/arm64/release/unnamed-monero-wallet.aarch64.rpm
