# Simulatore Android Multi-Device per Raspberry Pi 5

## Panoramica
Questo software permette di eseguire 3 istanze separate di Android su Raspberry Pi 5 con OS 64-bit, ognuna con la propria connessione di rete indipendente.

## Caratteristiche
- 3 dispositivi Android reali emulati (Pixel 6 Pro, Galaxy S23 Ultra, iPhone 14 Pro Max)
- TikTok preinstallato e configurato su tutti i dispositivi
- Connessioni di rete indipendenti per ogni istanza
- Interfaccia di controllo centralizzata
- Sistema di automazione per controllo dispositivi
- Ottimizzato per Raspberry Pi 5 64-bit

## Requisiti di Sistema
- Raspberry Pi 5 con OS 64-bit (Raspberry Pi OS o Ubuntu)
- Almeno 8GB RAM (raccomandato 16GB)
- 64GB+ spazio di archiviazione
- Connessione internet stabile

## Architettura
- **Container Manager**: Gestisce le 3 istanze Android
- **Network Manager**: Gestisce le connessioni separate
- **Control Interface**: Interfaccia web per controllo
- **Automation Engine**: Sistema di automazione

## Installazione
Vedi `install.sh` per l'installazione automatica.

## Dispositivi Emulati

### Android 1 - Google Pixel 6 Pro
- **Risoluzione**: 1440x3120 (560 DPI)
- **Android**: 13 (API 33)
- **ADB**: localhost:5555
- **Web**: localhost:8080
- **VNC**: localhost:5901
- **IP**: 172.20.1.10

### Android 2 - Samsung Galaxy S23 Ultra
- **Risoluzione**: 1440x3088 (515 DPI)
- **Android**: 13 (API 33)
- **ADB**: localhost:5556
- **Web**: localhost:8081
- **VNC**: localhost:5902
- **IP**: 172.20.2.10

### Android 3 - iPhone 14 Pro Max (Android)
- **Risoluzione**: 1290x2796 (460 DPI)
- **Android**: 13 (API 33)
- **ADB**: localhost:5557
- **Web**: localhost:8082
- **VNC**: localhost:5903
- **IP**: 172.20.3.10

## Utilizzo
```bash
./start_simulator.sh
```

## Struttura Progetto
```
├── containers/          # Configurazioni container Android
├── network/            # Configurazioni di rete
├── control/            # Interfaccia di controllo
├── automation/         # Script di automazione
├── scripts/            # Script di utilità
└── docs/              # Documentazione
```
