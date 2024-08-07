#!/bin/bash
set -e
set -x

# -f is here as a workaround
# https://t.me/SFOSFanclub/142531
zypper in -f -y cmake ffmpeg-tools git clang libxkbcommon-devel wayland-protocols-devel wayland-client wayland-egl-devel make glibc-static
mkdir -p $HOME/flutter-elinux
git clone https://github.com/sony/flutter-elinux.git $HOME/flutter-elinux/$(uname -m)

FVM_VERSION=$(cat .fvmrc  | grep flutter | xargs | awk '{ print $2 }')
pushd "$HOME/flutter-elinux/$(uname -m)"
    git checkout $FVM_VERSION
popd

echo 'export PATH="$PATH:$HOME/flutter-elinux/$(uname -m)/bin"' >> $HOME/.bashrc
echo 'export PATH="$PATH:$HOME/flutter-elinux/$(uname -m)/flutter/bin"' >> $HOME/.bashrc
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> $HOME/.bashrc

git config --global --add safe.directory $HOME/flutter-elinux/$(uname -m)/flutter
git config --global --add safe.directory $HOME/flutter-elinux/$(uname -m)
git config --global --add safe.directory '*' # screw it.

# not-so-temporary fix
curl -L --output /usr/include/linux/input-event-codes.h https://raw.githubusercontent.com/torvalds/linux/master/include/uapi/linux/input-event-codes.h
# end

if [[ ! -f "$HOME/SailfishOS/flutter-elinux/$(uname -m)/flutter-client" ]];
then
    echo "Flutter client not found, making one"
    pushd $(mktemp -d)
        git clone https://github.com/MrCyjaneK/flutter-embedded-linux
        cd flutter-embedded-linux
        mkdir build && cd build
        # hash in here doesn't matter, it is just to make the compiler happy.
        curl -L https://github.com/sony/flutter-embedded-linux/releases/download/c4cd48e186/elinux-arm64-release.zip --output elinux-arm64-release.zip
        unzip elinux-arm64-release.zip && rm elinux-arm64-release.zip
        cmake ..
        make -j$(nproc)
        mkdir -p $HOME/SailfishOS/flutter-elinux/$(uname -m)/
        cp flutter-client $HOME/SailfishOS/flutter-elinux/$(uname -m)/flutter-client
    popd
fi

