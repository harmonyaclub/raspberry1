# Guida Completa - Simulatore Android Multi-Device

## 🎯 Panoramica

Questo sistema permette di eseguire 3 istanze separate di Android su Raspberry Pi 5 con OS 64-bit, ognuna con connessione di rete indipendente e sistema di automazione avanzato.

## 📋 Requisiti di Sistema

### Hardware Minimo
- **Raspberry Pi 5** con OS 64-bit
- **RAM**: 8GB (raccomandato 16GB)
- **Storage**: 64GB+ (raccomandato 128GB)
- **Rete**: Connessione internet stabile
- **Alimentazione**: 27W (5V/5A) per performance ottimali

### Software Richiesto
- Raspberry Pi OS 64-bit o Ubuntu 22.04+
- Docker e Docker Compose
- QEMU/KVM per virtualizzazione
- Node.js per pannello di controllo

## 🚀 Installazione

### 1. Preparazione Sistema

```bash
# Ottimizza Raspberry Pi 5 per simulatori Android
sudo ./scripts/optimize_raspberry.sh

# Riavvia il sistema
sudo reboot
```

### 2. Installazione Software

```bash
# Esegui installazione automatica
./install.sh

# Configura reti separate
sudo ./scripts/setup_networking.sh
```

### 3. Avvio Simulatori

```bash
# Avvia tutti i simulatori
./start_simulator.sh

# Verifica stato
./scripts/monitor_system.sh
```

## 🖥️ Interfaccia di Controllo

### Accesso Web
- **URL**: http://localhost:3000
- **Funzionalità**:
  - Controllo 3 dispositivi Android
  - Screenshot in tempo reale
  - Input touch e tastiera
  - Sistema di automazione
  - Monitoraggio performance

### Controlli Disponibili

#### Controllo Dispositivi
- **Screenshot**: Acquisisci schermata del dispositivo
- **Tap**: Tocca lo schermo in coordinate specifiche
- **Swipe**: Scorri da un punto all'altro
- **Testo**: Inserisci testo tramite tastiera virtuale

#### Automazione
- **Script Predefiniti**:
  - Automazione Base: Test interazioni fondamentali
  - Test Applicazioni: Verifica funzionamento app
  - Test Performance: Stress test del sistema
- **Script Personalizzati**: Crea automazioni custom

## 📱 Gestione Dispositivi

### Connessioni ADB
```bash
# Android 1
adb connect localhost:5555

# Android 2  
adb connect localhost:5556

# Android 3
adb connect localhost:5557

# Lista dispositivi connessi
adb devices
```

### Porte di Accesso
- **Android 1**: ADB 5555, Web 8080, VNC 5901
- **Android 2**: ADB 5556, Web 8081, VNC 5902  
- **Android 3**: ADB 5557, Web 8082, VNC 5903
- **Pannello**: Web 3000

### Reti Separate
- **Android 1**: 172.20.1.0/24
- **Android 2**: 172.20.2.0/24
- **Android 3**: 172.20.3.0/24

## 🤖 Sistema di Automazione

### Script Predefiniti

#### 1. Automazione Base
```javascript
// Test interazioni fondamentali
tap 500 500          // Tap al centro
wait 1000            // Attesa 1 secondo
swipe 100 500 900 500 // Swipe orizzontale
text "Hello World"   // Inserimento testo
screenshot           // Screenshot finale
```

#### 2. Test Applicazioni
```javascript
// Testa app predefinite
launch com.android.settings
wait 3000
tap 500 500
wait 1000
key KEYCODE_HOME
```

#### 3. Test Performance
```javascript
// Stress test con operazioni multiple
for (i = 0; i < 10; i++) {
    tap 200 200
    tap 400 400  
    tap 600 600
    tap 800 800
    wait 1000
}
```

### Script Personalizzati

#### Sintassi Supportata
- `tap x y` - Tocca coordinate
- `swipe x1 y1 x2 y2` - Scorri tra punti
- `text "messaggio"` - Inserisci testo
- `key KEYCODE_*` - Premi tasto
- `wait ms` - Attesa in millisecondi
- `screenshot` - Acquisisci schermata
- `# commento` - Commenti

#### Esempio Script Personalizzato
```javascript
# Script di test personalizzato
tap 500 500
wait 2000
text "Test automazione"
wait 1000
swipe 100 500 900 500
wait 2000
screenshot
```

## 🔧 Gestione Sistema

### Monitoraggio Performance
```bash
# Avvia monitoraggio interattivo
./scripts/monitor_system.sh

# Opzioni disponibili:
# 1) Statistiche in tempo reale
# 2) Monitoraggio continuo
# 3) Log performance
# 4) Controllo alert
# 5) Ottimizzazione automatica
# 6) Riavvia simulatori
# 7) Ferma simulatori
```

### Gestione Container
```bash
# Stato container
docker ps

# Log container specifico
docker logs android_sim_1
docker logs android_sim_2
docker logs android_sim_3

# Riavvia container
docker restart android_sim_1

# Ferma tutti i simulatori
./stop_simulator.sh
```

### Risoluzione Problemi

#### Container non si avvia
```bash
# Verifica log
docker logs android_sim_1

# Riavvia Docker
sudo systemctl restart docker

# Pulisci cache
docker system prune -f
```

#### ADB non si connette
```bash
# Riavvia ADB
adb kill-server
adb start-server

# Riconnetti dispositivi
adb connect localhost:5555
adb connect localhost:5556
adb connect localhost:5557
```

#### Performance basse
```bash
# Verifica risorse
htop
free -h
df -h

# Ottimizza sistema
./scripts/optimize_raspberry.sh

# Pulisci memoria
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

## 📊 Monitoraggio e Log

### Log Sistema
- **Docker**: `docker logs <container_name>`
- **Sistema**: `/var/log/syslog`
- **Performance**: `/tmp/android_simulator_performance.log`

### Metriche Importanti
- **CPU**: < 80% utilizzo
- **Memoria**: < 90% utilizzo  
- **Container**: 3 attivi
- **ADB**: 3 dispositivi connessi
- **Rete**: Connessioni stabili

## 🔒 Sicurezza

### Configurazioni Sicurezza
- Reti isolate per ogni dispositivo
- NAT per connessioni internet
- Firewall configurato
- Accesso limitato alle porte

### Backup e Ripristino
```bash
# Backup configurazioni
tar -czf android_simulator_backup.tar.gz containers/ control/ scripts/

# Ripristino
tar -xzf android_simulator_backup.tar.gz
```

## 🚀 Ottimizzazioni Avanzate

### Performance
- CPU in modalità performance
- GPU ottimizzata per virtualizzazione
- Memoria swap configurata
- Cache ottimizzate

### Rete
- Bridge separati per ogni dispositivo
- NAT configurato
- QoS per traffico prioritario
- Monitoraggio banda

### Storage
- Overlay2 per Docker
- Log rotation configurato
- Pulizia automatica
- Monitoraggio spazio

## 📞 Supporto

### Log di Debug
```bash
# Raccogli informazioni sistema
./scripts/monitor_system.sh > debug_info.txt

# Invia log per supporto
tar -czf debug_package.tar.gz debug_info.txt /var/log/android-simulator/
```

### Comandi Utili
```bash
# Stato completo sistema
systemctl status docker
docker-compose ps
adb devices
ip addr show

# Performance in tempo reale
htop
iotop
nethogs
```

## 🎯 Prossimi Sviluppi

### Funzionalità Pianificate
- [ ] Supporto per più dispositivi (fino a 6)
- [ ] Interfaccia mobile per controllo remoto
- [ ] Integrazione con CI/CD
- [ ] Template di automazione predefiniti
- [ ] Dashboard analytics avanzato
- [ ] Supporto per app APK personalizzate

### Miglioramenti Performance
- [ ] Ottimizzazione memoria
- [ ] Accelerazione hardware
- [ ] Load balancing automatico
- [ ] Caching intelligente

---

**Sviluppato per Raspberry Pi 5 con OS 64-bit**  
**Versione**: 1.0.0  
**Data**: $(date)  
**Autore**: Simone
