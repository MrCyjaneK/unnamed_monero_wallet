FROM ghcr.io/cirruslabs/android-sdk:34

# Fix the image

RUN rm /root/.gitconfig

# Install dependencies

RUN apt update \
    && apt install -y curl git unzip pkg-config ninja-build cmake clang libgtk-3-dev zsh

# Install zsh and configure it

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" \
    -t robbyrussell

# Install fvm

RUN curl -fsSL https://fvm.app/install.sh | bash \
    && echo -n '#!/bin/bash\nfvm flutter $@' > /bin/flutter \
    && echo -n '#!/bin/bash\nfvm dart $@' > /bin/dart \
    && chmod +x /bin/flutter /bin/dart
