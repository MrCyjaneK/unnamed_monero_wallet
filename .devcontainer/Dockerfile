FROM ghcr.io/cirruslabs/android-sdk:34

# Fix the image

RUN rm /root/.gitconfig

# Install dependencies

RUN apt update \
    && apt install -y sudo curl git unzip pkg-config ninja-build cmake clang libgtk-3-dev zsh

USER ubuntu
WORKDIR /home/ubuntu

RUN sudo chown -R $(whoami) /sdks /opt

# Fix the image

RUN sudo rm /root/.gitconfig
RUN bash -c 'if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] then sudo rm -rf /opt/android-sdk-linux/platform-tools; fi'

# Install zsh and configure it

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" \
    -t robbyrussell

# Install fvm

RUN curl -fsSL https://fvm.app/install.sh | bash \
    && echo -n '#!/bin/bash\nfvm flutter $@' > /bin/flutter \
    && echo -n '#!/bin/bash\nfvm dart $@' > /bin/dart \
    && chmod +x /bin/flutter /bin/dart
