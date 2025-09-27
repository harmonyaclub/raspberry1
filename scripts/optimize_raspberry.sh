#!/bin/bash

# Script per ottimizzare Raspberry Pi 5 per simulatori Android

echo "🚀 Ottimizzazione Raspberry Pi 5 per Simulatori Android"
echo "======================================================"

# Verifica se è root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Questo script deve essere eseguito come root"
    echo "   Usa: sudo ./optimize_raspberry.sh"
    exit 1
fi

echo "📋 Applicazione ottimizzazioni..."

# 1. Configurazione GPU
echo "🎮 Configurazione GPU..."
cat > /boot/config.txt << 'EOF'
# Configurazione ottimizzata per simulatori Android
gpu_mem=256
gpu_mem_256=1
gpu_mem_512=1
gpu_mem_1024=1

# Overclock GPU per migliori performance
gpu_freq=500

# Abilita hardware acceleration
dtoverlay=vc4-kms-v3d
dtoverlay=vc4-kms-v3d-pi4

# Configurazione display
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82
hdmi_cvt=1920 1080 60 6 0 0 0

# Configurazione audio
dtparam=audio=on
audio_pwm_mode=2

# Configurazione USB
dtoverlay=dwc2
dtoverlay=usbhost

# Configurazione rete
dtparam=eth0=none
dtparam=eth1=none
EOF

# 2. Configurazione memoria e swap
echo "💾 Configurazione memoria..."
cat > /etc/sysctl.conf << 'EOF'
# Ottimizzazioni memoria per simulatori Android
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=15
vm.dirty_background_ratio=5
vm.dirty_expire_centisecs=3000
vm.dirty_writeback_centisecs=500

# Configurazione rete
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 87380 134217728
net.ipv4.tcp_wmem=4096 65536 134217728
net.core.netdev_max_backlog=5000
net.ipv4.tcp_congestion_control=bbr

# Abilita IP forwarding per container
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

# 3. Configurazione CPU
echo "⚡ Configurazione CPU..."
cat > /etc/default/cpufrequtils << 'EOF'
# Configurazione CPU per simulatori Android
GOVERNOR=performance
MAX_SPEED=2400000
MIN_SPEED=1500000
EOF

# 4. Configurazione Docker
echo "🐳 Configurazione Docker..."
cat > /etc/docker/daemon.json << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "default-ulimits": {
        "memlock": {
            "Hard": -1,
            "Name": "memlock",
            "Soft": -1
        }
    },
    "default-runtime": "runc",
    "runtimes": {
        "runc": {
            "path": "runc"
        }
    }
}
EOF

# 5. Configurazione sistema
echo "🔧 Configurazione sistema..."

# Aumenta limiti di file
cat >> /etc/security/limits.conf << 'EOF'
# Limiti per simulatori Android
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
root soft nofile 65536
root hard nofile 65536
root soft nproc 32768
root hard nproc 32768
EOF

# Configurazione kernel
cat >> /etc/sysctl.conf << 'EOF'
# Configurazione kernel per simulatori Android
kernel.pid_max=4194304
fs.file-max=2097152
kernel.threads-max=2097152
vm.max_map_count=262144
EOF

# 6. Configurazione QEMU/KVM
echo "🖥️ Configurazione QEMU/KVM..."

# Abilita KVM
modprobe kvm
modprobe kvm_arm
echo 'kvm' >> /etc/modules
echo 'kvm_arm' >> /etc/modules

# Configurazione per virtualizzazione
echo 'vmx' >> /etc/modules
echo 'svm' >> /etc/modules

# 7. Configurazione rete per container
echo "🌐 Configurazione rete container..."

# Crea directory per configurazioni di rete
mkdir -p /etc/systemd/network

# Configurazione bridge
cat > /etc/systemd/network/android-bridges.netdev << 'EOF'
[NetDev]
Name=android1-br
Kind=bridge

[NetDev]
Name=android2-br
Kind=bridge

[NetDev]
Name=android3-br
Kind=bridge
EOF

cat > /etc/systemd/network/android-bridges.network << 'EOF'
[Match]
Name=android1-br

[Network]
Address=172.20.1.1/24
DHCPServer=yes

[Match]
Name=android2-br

[Network]
Address=172.20.2.1/24
DHCPServer=yes

[Match]
Name=android3-br

[Network]
Address=172.20.3.1/24
DHCPServer=yes
EOF

# 8. Configurazione servizi
echo "⚙️ Configurazione servizi..."

# Abilita servizi necessari
systemctl enable docker
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Configurazione cron per pulizia automatica
cat > /etc/cron.d/android-simulator-cleanup << 'EOF'
# Pulizia automatica per simulatori Android
0 2 * * * root /usr/bin/docker system prune -f
0 3 * * * root /bin/echo 3 > /proc/sys/vm/drop_caches
EOF

# 9. Configurazione logrotate
echo "📝 Configurazione logrotate..."
cat > /etc/logrotate.d/android-simulator << 'EOF'
/var/log/android-simulator/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# 10. Configurazione swap
echo "💾 Configurazione swap..."
# Crea swap file se non esiste
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# 11. Ottimizzazioni finali
echo "🔧 Applicazione ottimizzazioni finali..."

# Applica configurazioni
sysctl -p

# Riavvia servizi
systemctl restart systemd-networkd
systemctl restart systemd-resolved
systemctl restart docker

# Crea directory per log
mkdir -p /var/log/android-simulator

echo ""
echo "✅ Ottimizzazione completata!"
echo ""
echo "📋 Configurazioni applicate:"
echo "   ✅ GPU ottimizzata per virtualizzazione"
echo "   ✅ Memoria e swap configurati"
echo "   ✅ CPU in modalità performance"
echo "   ✅ Docker ottimizzato"
echo "   ✅ Reti container configurate"
echo "   ✅ Limiti sistema aumentati"
echo "   ✅ KVM abilitato"
echo "   ✅ Pulizia automatica configurata"
echo ""
echo "⚠️  IMPORTANTE: Riavvia il sistema per applicare tutte le modifiche!"
echo "   sudo reboot"
echo ""
echo "🚀 Dopo il riavvio, esegui:"
echo "   ./install.sh"
echo "   ./start_simulator.sh"
