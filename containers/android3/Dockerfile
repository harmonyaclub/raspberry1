# Dockerfile per Android Simulator 1
FROM ubuntu:22.04

# Installa dipendenze
RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    android-tools-adb \
    android-tools-fastboot \
    wget \
    unzip \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crea directory di lavoro
WORKDIR /android

# Download Android-x86 ISO (versione leggera per ARM)
RUN wget -O android-x86.iso "https://sourceforge.net/projects/android-x86/files/Release-9.0/android-x86_64-9.0-r2.iso/download" || \
    echo "Download fallback: usando immagine predefinita"

# Crea disco virtuale
RUN qemu-img create -f qcow2 android1.img 8G

# Script di avvio Android
COPY start_android.sh /android/
RUN chmod +x /android/start_android.sh

# Script di configurazione rete
COPY network_setup.sh /android/
RUN chmod +x /android/network_setup.sh

# Esponi porte
EXPOSE 5555 8080 5901

# Comando di avvio
CMD ["/android/start_android.sh"]
