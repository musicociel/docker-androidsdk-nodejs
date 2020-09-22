FROM archlinux/base:latest

RUN echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf \
    && pacman --noconfirm -Syu nodejs yarn npm base-devel git jdk8-openjdk audit go gradle sudo unzip rsync openssh docker wine wine-mono mono \
    && useradd user -m \
    && echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user

RUN cd /home/user \
    && git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg --noconfirm -si

RUN PKGEXT=.pkg.tar yay --noconfirm -S android-sdk-dummy android-sdk-build-tools-dummy fdroidserver

ENV ANDROID_SDK_ROOT=/home/user/android-sdk JAVA_HOME=/usr/lib/jvm/default

# https://developer.android.com/studio#cmdline-tools
RUN mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools" \
    && cd "$ANDROID_SDK_ROOT/cmdline-tools" \
    && curl https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip -o tools.zip \
    && echo "89f308315e041c93a37a79e0627c47f21d5c5edbe5e80ea8dc0aac8a649e0e92 tools.zip" | sha256sum -c \
    && unzip tools.zip \
    && rm tools.zip

RUN yes | "$ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager" "platform-tools" "build-tools;29.0.3" "platforms;android-29" "ndk;21.0.6113669" "cmake;3.10.2.4988404"

RUN sudo npm install -g cordova

RUN cordova telemetry off
RUN cd /home/user \
    && cordova create hello com.example.hello HelloWorld \
    && cd hello \
    && cordova platform add android \
    && cordova build android \
    && cd /home/user \
    && rm -rf hello
