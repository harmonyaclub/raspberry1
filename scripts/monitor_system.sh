#!/bin/bash

# Script per monitorare le performance del sistema e dei simulatori

echo "📊 Monitoraggio Sistema Simulatori Android"
echo "=========================================="

# Funzione per mostrare statistiche
show_stats() {
    clear
    echo "📊 Monitoraggio Sistema - $(date)"
    echo "=========================================="
    
    # CPU e Memoria
    echo "💻 Risorse Sistema:"
    echo "   CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)% utilizzata"
    echo "   Memoria: $(free -h | awk 'NR==2{printf "%.1f%%", $3*100/$2}') utilizzata"
    echo "   Swap: $(free -h | awk 'NR==3{printf "%.1f%%", $3*100/$2}') utilizzata"
    echo ""
    
    # Docker containers
    echo "🐳 Container Docker:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep android
    echo ""
    
    # Rete
    echo "🌐 Reti:"
    ip addr show | grep -E "(android.*-br|172\.20\.)" | head -6
    echo ""
    
    # ADB devices
    echo "📱 Dispositivi ADB:"
    adb devices
    echo ""
    
    # Porte in ascolto
    echo "🔌 Porte in ascolto:"
    netstat -tlnp | grep -E "(5555|5556|5557|3000|8080|8081|8082|5901|5902|5903)"
    echo ""
    
    # Spazio disco
    echo "💾 Spazio Disco:"
    df -h | grep -E "(Filesystem|/dev/root|/dev/sda)"
    echo ""
}

# Funzione per log delle performance
log_performance() {
    local log_file="/tmp/android_simulator_performance.log"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    
    # Memory usage
    local mem_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    
    # Docker containers running
    local containers_running=$(docker ps | grep android | wc -l)
    
    # ADB devices connected
    local adb_devices=$(adb devices | grep -v "List of devices" | grep "device" | wc -l)
    
    echo "$timestamp,CPU:$cpu_usage%,MEM:$mem_usage%,CONTAINERS:$containers_running,ADB:$adb_devices" >> "$log_file"
}

# Funzione per alert
check_alerts() {
    # CPU alta
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d',' -f1)
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        echo "⚠️  ALERT: CPU usage alta: ${cpu_usage}%"
    fi
    
    # Memoria bassa
    local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [ "$mem_usage" -gt 90 ]; then
        echo "⚠️  ALERT: Memoria bassa: ${mem_usage}%"
    fi
    
    # Container non in esecuzione
    local containers_running=$(docker ps | grep android | wc -l)
    if [ "$containers_running" -lt 3 ]; then
        echo "⚠️  ALERT: Solo $containers_running container Android in esecuzione"
    fi
    
    # ADB devices disconnessi
    local adb_devices=$(adb devices | grep -v "List of devices" | grep "device" | wc -l)
    if [ "$adb_devices" -lt 3 ]; then
        echo "⚠️  ALERT: Solo $adb_devices dispositivi ADB connessi"
    fi
}

# Funzione per ottimizzazione automatica
auto_optimize() {
    echo "🔧 Ottimizzazione automatica..."
    
    # Pulisci cache Docker
    docker system prune -f > /dev/null 2>&1
    
    # Riavvia ADB se necessario
    local adb_devices=$(adb devices | grep -v "List of devices" | grep "device" | wc -l)
    if [ "$adb_devices" -eq 0 ]; then
        echo "🔄 Riavvio ADB server..."
        adb kill-server
        adb start-server
        sleep 2
        adb connect localhost:5555
        adb connect localhost:5556
        adb connect localhost:5557
    fi
    
    # Ottimizza memoria
    echo 3 > /proc/sys/vm/drop_caches > /dev/null 2>&1
}

# Menu principale
show_menu() {
    echo ""
    echo "📋 Menu Monitoraggio:"
    echo "1) Mostra statistiche in tempo reale"
    echo "2) Monitoraggio continuo (5 secondi)"
    echo "3) Log performance"
    echo "4) Controllo alert"
    echo "5) Ottimizzazione automatica"
    echo "6) Riavvia simulatori"
    echo "7) Ferma simulatori"
    echo "8) Esci"
    echo ""
    read -p "Seleziona opzione (1-8): " choice
}

# Gestione opzioni
handle_choice() {
    case $1 in
        1)
            show_stats
            ;;
        2)
            echo "🔄 Monitoraggio continuo (Ctrl+C per fermare)..."
            while true; do
                show_stats
                check_alerts
                sleep 5
            done
            ;;
        3)
            echo "📝 Log performance salvato in /tmp/android_simulator_performance.log"
            log_performance
            ;;
        4)
            check_alerts
            ;;
        5)
            auto_optimize
            echo "✅ Ottimizzazione completata"
            ;;
        6)
            echo "🔄 Riavvio simulatori..."
            cd "$(dirname "$0")/.."
            ./stop_simulator.sh
            sleep 5
            ./start_simulator.sh
            ;;
        7)
            echo "🛑 Arresto simulatori..."
            cd "$(dirname "$0")/.."
            ./stop_simulator.sh
            ;;
        8)
            echo "👋 Arrivederci!"
            exit 0
            ;;
        *)
            echo "❌ Opzione non valida"
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    handle_choice "$choice"
    
    if [ "$choice" != "2" ]; then
        read -p "Premi Enter per continuare..."
    fi
done
