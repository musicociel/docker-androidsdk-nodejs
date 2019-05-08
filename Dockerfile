FROM archlinux/base:latest

RUN echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf \
    && pacman --noconfirm -Syu \
    && pacman --noconfirm -S nodejs yarn npm base-devel git jdk8-openjdk audit go gradle sudo unzip rsync openssh docker wine wine-mono mono \
    && useradd user -m \
    && echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user

RUN cd /home/user \
    && git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg --noconfirm -si \
    && cd .. \
    && rm -rf yay \
    && PKGEXT=.pkg.tar yay --noconfirm -S android-sdk-dummy android-sdk-build-tools-dummy fdroidserver ncurses5-compat-libs \
    && mkdir android-sdk \
    && cd android-sdk \
    && curl https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -o tools.zip \
    && echo "92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9 tools.zip" | sha256sum -c \
    && unzip tools.zip \
    && rm tools.zip \
    && curl https://dl.google.com/android/repository/android-ndk-r17c-linux-x86_64.zip -o ndk.zip \
    && echo "12cacc70c3fd2f40574015631c00f41fb8a39048 ndk.zip" | sha1sum -c \
    && unzip ndk.zip \
    && rm ndk.zip \
    && mv android-ndk-r17c ndk-bundle \
    && yes | ./tools/bin/sdkmanager "platform-tools" "build-tools;26.0.3" "platforms;android-26" "cmake;3.6.4111459"

ENV ANDROID_HOME=/home/user/android-sdk JAVA_HOME=/usr/lib/jvm/default
