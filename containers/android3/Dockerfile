# Dockerfile per Android Emulator 3 - iPhone 14 Pro Max (Android)
FROM ubuntu:22.04

# Installa dipendenze per Android Emulator
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    android-tools-adb \
    android-tools-fastboot \
    wget \
    unzip \
    curl \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    libc6-dev \
    lib32stdc++6 \
    lib32z1 \
    lib32ncurses6 \
    lib32bz2-1.0 \
    lib32gcc-s1 \
    lib32gcc1 \
    libc6-i386 \
    && rm -rf /var/lib/apt/lists/*

# Installa Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

# Crea directory Android SDK
RUN mkdir -p $ANDROID_HOME

# Download Android SDK Command Line Tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /tmp && \
    mkdir -p $ANDROID_HOME/cmdline-tools && \
    mv /tmp/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# Accetta licenze Android
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses

# Installa componenti Android SDK
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-33" \
    "platforms;android-32" \
    "platforms;android-31" \
    "build-tools;33.0.0" \
    "build-tools;32.0.0" \
    "emulator" \
    "system-images;android-33;google_apis;x86_64" \
    "system-images;android-32;google_apis;x86_64" \
    "system-images;android-31;google_apis;x86_64"

# Crea AVD (Android Virtual Device) per TikTok
# Dispositivo: iPhone 14 Pro Max (Android) (compatibile con TikTok)
RUN echo "no" | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
    -n "iPhone14ProMax_Android3" \
    -k "system-images;android-33;google_apis;x86_64" \
    -d "pixel_6_pro" \
    --force

# Configura AVD per TikTok (iPhone 14 Pro Max)
RUN mkdir -p /root/.android/avd/iPhone14ProMax_Android3.avd && \
    cat > /root/.android/avd/iPhone14ProMax_Android3.avd/config.ini << 'EOF'
avd.ini.encoding=UTF-8
abi.type=x86_64
avd.ini.displayname=iPhone 14 Pro Max Android 3
hw.accelerometer=yes
hw.audioInput=yes
hw.audioOutput=yes
hw.battery=yes
hw.camera.back=webcam0
hw.camera.front=webcam0
hw.cpu.arch=x86_64
hw.cpu.ncore=4
hw.dPad=no
hw.gps=yes
hw.gpu.enabled=yes
hw.gpu.mode=auto
hw.initialOrientation=portrait
hw.keyboard=yes
hw.lcd.density=460
hw.lcd.height=2796
hw.lcd.width=1290
hw.mainKeys=no
hw.ramSize=4096
hw.screen.back=no
hw.sdCard=yes
hw.sensors.orientation=yes
hw.sensors.proximity=yes
hw.trackBall=no
hw.usbStorage=yes
image.sysdir.1=system-images/android-33/google_apis/x86_64/
skin.dynamic=yes
skin.name=pixel_6_pro
skin.path=skins/pixel_6_pro
tag.display=Google APIs
tag.id=google_apis
vm.heapSize=512
EOF

# Crea script di avvio emulatore
COPY start_android.sh /android/
RUN chmod +x /android/start_android.sh

# Script di configurazione rete
COPY network_setup.sh /android/
RUN chmod +x /android/network_setup.sh

# Script per installare TikTok
COPY install_tiktok.sh /android/
RUN chmod +x /android/install_tiktok.sh

# Esponi porte
EXPOSE 5557 8082 5903

# Comando di avvio
CMD ["/android/start_android.sh"]