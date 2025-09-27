#!/bin/bash

# Script di installazione per Simulatore Android Multi-Device
# Raspberry Pi 5 64-bit

set -e

echo "🚀 Installazione Simulatore Android Multi-Device per Raspberry Pi 5"
echo "=================================================================="

# Verifica architettura
if [ "$(uname -m)" != "aarch64" ]; then
    echo "❌ Errore: Questo script è progettato per architettura ARM64 (aarch64)"
    echo "   Architettura rilevata: $(uname -m)"
    exit 1
fi

# Verifica se è root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Non eseguire questo script come root"
    exit 1
fi

echo "✅ Architettura ARM64 verificata"

# Aggiorna sistema
echo "📦 Aggiornamento sistema..."
sudo apt update && sudo apt upgrade -y

# Installa dipendenze
echo "📦 Installazione dipendenze..."
sudo apt install -y \
    docker.io \
    docker-compose \
    qemu-system-x86 \
    qemu-utils \
    virt-manager \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    netfilter-persistent \
    iptables-persistent \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    git \
    curl \
    wget \
    unzip \
    jq \
    htop \
    vim

# Aggiungi utente al gruppo docker
echo "👤 Configurazione utente per Docker..."
sudo usermod -aG docker $USER
sudo usermod -aG libvirt $USER

# Abilita servizi
echo "🔧 Abilitazione servizi..."
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Crea directory del progetto
echo "📁 Creazione struttura directory..."
mkdir -p containers/{android1,android2,android3}
mkdir -p network/{configs,scripts}
mkdir -p control/{web,api}
mkdir -p automation/{scripts,configs}
mkdir -p scripts
mkdir -p docs

# Crea file di configurazione
echo "⚙️ Creazione file di configurazione..."

# Configurazione Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  android1:
    build: ./containers/android1
    container_name: android_sim_1
    privileged: true
    devices:
      - /dev/kvm:/dev/kvm
    networks:
      - android1_net
    ports:
      - "5555:5555"  # ADB
      - "8080:8080"  # Web interface
    environment:
      - ANDROID_ID=1
      - VNC_PORT=5901
    volumes:
      - android1_data:/data
      - ./shared:/shared

  android2:
    build: ./containers/android2
    container_name: android_sim_2
    privileged: true
    devices:
      - /dev/kvm:/dev/kvm
    networks:
      - android2_net
    ports:
      - "5556:5555"  # ADB
      - "8081:8080"  # Web interface
    environment:
      - ANDROID_ID=2
      - VNC_PORT=5902
    volumes:
      - android2_data:/data
      - ./shared:/shared

  android3:
    build: ./containers/android3
    container_name: android_sim_3
    privileged: true
    devices:
      - /dev/kvm:/dev/kvm
    networks:
      - android3_net
    ports:
      - "5557:5555"  # ADB
      - "8082:8080"  # Web interface
    environment:
      - ANDROID_ID=3
      - VNC_PORT=5903
    volumes:
      - android3_data:/data
      - ./shared:/shared

  control_panel:
    build: ./control
    container_name: control_panel
    ports:
      - "3000:3000"
    volumes:
      - ./control:/app
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - android1
      - android2
      - android3

networks:
  android1_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.1.0/24
  android2_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.2.0/24
  android3_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.3.0/24

volumes:
  android1_data:
  android2_data:
  android3_data:
EOF

# Script di avvio
cat > start_simulator.sh << 'EOF'
#!/bin/bash

echo "🚀 Avvio Simulatore Android Multi-Device"
echo "========================================"

# Verifica Docker
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker non è in esecuzione. Avvio Docker..."
    sudo systemctl start docker
    sleep 5
fi

# Crea rete di default se non esiste
docker network create android_default 2>/dev/null || true

# Avvia i container
echo "📱 Avvio istanze Android..."
docker-compose up -d

# Attendi che i container siano pronti
echo "⏳ Attesa avvio container..."
sleep 30

# Verifica stato
echo "📊 Stato container:"
docker-compose ps

echo ""
echo "✅ Simulatore avviato!"
echo "🌐 Pannello di controllo: http://localhost:3000"
echo "📱 Android 1: ADB porta 5555, Web porta 8080"
echo "📱 Android 2: ADB porta 5556, Web porta 8081"
echo "📱 Android 3: ADB porta 5557, Web porta 8082"
echo ""
echo "Per fermare: ./stop_simulator.sh"
EOF

# Script di stop
cat > stop_simulator.sh << 'EOF'
#!/bin/bash

echo "🛑 Arresto Simulatore Android Multi-Device"
echo "========================================="

docker-compose down

echo "✅ Simulatore fermato!"
EOF

# Rendi eseguibili gli script
chmod +x start_simulator.sh stop_simulator.sh

echo ""
echo "✅ Installazione completata!"
echo ""
echo "📋 Prossimi passi:"
echo "1. Riavvia il sistema per applicare le modifiche ai gruppi utente"
echo "2. Esegui: ./start_simulator.sh"
echo "3. Apri http://localhost:3000 per il pannello di controllo"
echo ""
echo "⚠️  IMPORTANTE: Riavvia il sistema prima di utilizzare il simulatore!"
