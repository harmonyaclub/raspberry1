#!/bin/bash

# Script di avvio per Android Emulator 1 - Pixel 6 Pro

echo "🚀 Avvio Android Emulator 1 - Pixel 6 Pro"

# Configura rete
/android/network_setup.sh

# Avvia VNC server per interfaccia grafica
Xvfb :1 -screen 0 1440x3120x24 &
export DISPLAY=:1

# Avvia desktop environment
fluxbox &
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -rfbport 5901 &

# Configura variabili ambiente
export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools

# Avvia Android Emulator (Pixel 6 Pro)
echo "📱 Avvio Android Emulator Pixel 6 Pro..."
$ANDROID_HOME/emulator/emulator \
    -avd Pixel6Pro_Android1 \
    -no-audio \
    -no-window \
    -gpu swiftshader_indirect \
    -memory 4096 \
    -cores 4 \
    -skin 1440x3120 \
    -netdelay none \
    -netspeed full \
    -port 5555 \
    -no-snapshot \
    -wipe-data \
    -no-boot-anim \
    -no-snapshot-load \
    -no-snapshot-save \
    -camera-back webcam0 \
    -camera-front webcam0 \
    -accel on \
    -qemu -enable-kvm &

# Attendi che l'emulatore sia pronto
echo "⏳ Attesa avvio emulatore Android..."
sleep 60

# Avvia ADB server
echo "🔌 Avvio ADB server..."
adb start-server

# Attendi connessione ADB
echo "📱 Connessione ADB..."
for i in {1..30}; do
    if adb devices | grep -q "emulator-5555.*device"; then
        echo "✅ ADB connesso!"
        break
    fi
    echo "⏳ Tentativo $i/30..."
    sleep 10
done

# Installa TikTok automaticamente
echo "📱 Installazione TikTok..."
/android/install_tiktok.sh

# Avvia web server per interfaccia di controllo
echo "🌐 Avvio web server..."
python3 -m http.server 8080 &

# Mantieni container attivo
echo "✅ Android Emulator 1 (Pixel 6 Pro) pronto!"
echo "📱 ADB: localhost:5555"
echo "🌐 Web: localhost:8080"
echo "🖥️  VNC: localhost:5901"
echo "📱 Dispositivo: Google Pixel 6 Pro (1440x3120)"

# Loop infinito per mantenere container attivo
while true; do
    sleep 30
    # Verifica che l'emulatore sia ancora attivo
    if ! pgrep -f "emulator.*Pixel6Pro_Android1" > /dev/null; then
        echo "⚠️ Emulatore non è più in esecuzione, riavvio..."
        $ANDROID_HOME/emulator/emulator \
            -avd Pixel6Pro_Android1 \
            -no-audio \
            -no-window \
            -gpu swiftshader_indirect \
            -memory 4096 \
            -cores 4 \
            -skin 1440x3120 \
            -netdelay none \
            -netspeed full \
            -port 5555 \
            -no-snapshot \
            -wipe-data \
            -no-boot-anim \
            -no-snapshot-load \
            -no-snapshot-save \
            -camera-back webcam0 \
            -camera-front webcam0 \
            -accel on \
            -qemu -enable-kvm &
    fi
done