#!/bin/bash

# Script di avvio per Android Simulator 1

echo "🚀 Avvio Android Simulator 1..."

# Configura rete
/android/network_setup.sh

# Avvia VNC server per interfaccia grafica
Xvfb :1 -screen 0 1024x768x24 &
export DISPLAY=:1

# Avvia desktop environment
fluxbox &
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -rfbport 5901 &

# Avvia Android in QEMU
echo "📱 Avvio Android in QEMU..."
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -m 2G \
    -smp 2 \
    -drive file=/android/android1.img,format=qcow2 \
    -cdrom /android/android-x86.iso \
    -boot d \
    -netdev user,id=net0,hostfwd=tcp::5555-:5555,hostfwd=tcp::8080-:8080 \
    -device e1000,netdev=net0 \
    -vnc :1 \
    -daemonize

# Avvia ADB server
echo "🔌 Avvio ADB server..."
adb start-server

# Attendi che Android sia pronto
echo "⏳ Attesa avvio Android..."
sleep 60

# Connessione ADB
echo "📱 Connessione ADB..."
adb connect localhost:5555

# Avvia web server per interfaccia di controllo
echo "🌐 Avvio web server..."
python3 -m http.server 8080 &

# Mantieni container attivo
echo "✅ Android Simulator 1 pronto!"
echo "📱 ADB: localhost:5555"
echo "🌐 Web: localhost:8080"
echo "🖥️  VNC: localhost:5901"

# Loop infinito per mantenere container attivo
while true; do
    sleep 30
    # Verifica che i processi siano ancora attivi
    if ! pgrep -f "qemu-system-x86_64" > /dev/null; then
        echo "⚠️ QEMU non è più in esecuzione, riavvio..."
        qemu-system-x86_64 \
            -enable-kvm \
            -cpu host \
            -m 2G \
            -smp 2 \
            -drive file=/android/android1.img,format=qcow2 \
            -cdrom /android/android-x86.iso \
            -boot d \
            -netdev user,id=net0,hostfwd=tcp::5555-:5555,hostfwd=tcp::8080-:8080 \
            -device e1000,netdev=net0 \
            -vnc :1 \
            -daemonize
    fi
done
