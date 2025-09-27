# Simulatore Android Multi-Device per Raspberry Pi 5

## Panoramica
Questo software permette di eseguire 3 istanze separate di Android su Raspberry Pi 5 con OS 64-bit, ognuna con la propria connessione di rete indipendente.

## Caratteristiche
- 3 istanze Android completamente separate
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
