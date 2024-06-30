FROM ghcr.io/cirruslabs/android-sdk:34

# Fix the image

RUN rm /root/.gitconfig
RUN bash -c 'if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] then rm -rf /opt/android-sdk-linux/platform-tools; fi'
# Install dependencies

RUN apt update \
    && apt install -y curl git unzip pkg-config ninja-build cmake clang libgtk-3-dev zsh

# Install zsh and configure it

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" \
    -t robbyrussell

# Install fvm

RUN curl -fsSL https://fvm.app/install.sh  | sed 's/arm64)/arm64|aarch64)/g' | bash