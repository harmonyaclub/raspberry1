#!/bin/bash

# Script di avvio per Android Emulator 2 - Samsung Galaxy S23 Ultra

echo "🚀 Avvio Android Emulator 2 - Samsung Galaxy S23 Ultra"

# Configura rete
/android/network_setup.sh

# Avvia VNC server per interfaccia grafica
Xvfb :1 -screen 0 1440x3088x24 &
export DISPLAY=:1

# Avvia desktop environment
fluxbox &
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -rfbport 5902 &

# Configura variabili ambiente
export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools

# Avvia Android Emulator (Galaxy S23 Ultra)
echo "📱 Avvio Android Emulator Galaxy S23 Ultra..."
$ANDROID_HOME/emulator/emulator \
    -avd GalaxyS23Ultra_Android2 \
    -no-audio \
    -no-window \
    -gpu swiftshader_indirect \
    -memory 4096 \
    -cores 4 \
    -skin 1440x3088 \
    -netdelay none \
    -netspeed full \
    -port 5556 \
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
    if adb devices | grep -q "emulator-5556.*device"; then
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
python3 -m http.server 8081 &

# Mantieni container attivo
echo "✅ Android Emulator 2 (Galaxy S23 Ultra) pronto!"
echo "📱 ADB: localhost:5556"
echo "🌐 Web: localhost:8081"
echo "🖥️  VNC: localhost:5902"
echo "📱 Dispositivo: Samsung Galaxy S23 Ultra (1440x3088)"

# Loop infinito per mantenere container attivo
while true; do
    sleep 30
    # Verifica che l'emulatore sia ancora attivo
    if ! pgrep -f "emulator.*GalaxyS23Ultra_Android2" > /dev/null; then
        echo "⚠️ Emulatore non è più in esecuzione, riavvio..."
        $ANDROID_HOME/emulator/emulator \
            -avd GalaxyS23Ultra_Android2 \
            -no-audio \
            -no-window \
            -gpu swiftshader_indirect \
            -memory 4096 \
            -cores 4 \
            -skin 1440x3088 \
            -netdelay none \
            -netspeed full \
            -port 5556 \
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