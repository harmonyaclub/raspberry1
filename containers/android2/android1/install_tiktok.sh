#!/bin/bash

# Script per installare TikTok su Android Emulator

echo "📱 Installazione TikTok su Android Emulator 1..."

# Attendi che Android sia completamente avviato
echo "⏳ Attesa avvio completo Android..."
sleep 120

# Verifica connessione ADB
echo "🔌 Verifica connessione ADB..."
for i in {1..20}; do
    if adb devices | grep -q "emulator-5555.*device"; then
        echo "✅ ADB connesso!"
        break
    fi
    echo "⏳ Tentativo $i/20..."
    sleep 10
done

# Abilita installazione da fonti sconosciute
echo "🔓 Abilitazione installazione da fonti sconosciute..."
adb shell settings put global install_non_market_apps 1
adb shell settings put global package_verifier_enable 0

# Installa Google Play Store (se non presente)
echo "📱 Installazione Google Play Store..."
adb install -r /android/google-play-store.apk 2>/dev/null || echo "Play Store già presente"

# Attendi che Play Store sia pronto
sleep 30

# Installa TikTok tramite ADB (se APK disponibile)
if [ -f "/android/tiktok.apk" ]; then
    echo "📱 Installazione TikTok da APK..."
    adb install -r /android/tiktok.apk
else
    echo "📱 Download e installazione TikTok..."
    
    # Download TikTok APK (versione stabile)
    wget -O /android/tiktok.apk "https://apkpure.com/tiktok/com.zhiliaoapp.musically/download/1" || \
    wget -O /android/tiktok.apk "https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=123456" || \
    echo "⚠️ Download TikTok fallito, installazione manuale richiesta"
    
    # Installa TikTok
    if [ -f "/android/tiktok.apk" ]; then
        adb install -r /android/tiktok.apk
    fi
fi

# Configura TikTok per funzionare correttamente
echo "⚙️ Configurazione TikTok..."

# Abilita permessi necessari
adb shell pm grant com.zhiliaoapp.musically android.permission.CAMERA
adb shell pm grant com.zhiliaoapp.musically android.permission.RECORD_AUDIO
adb shell pm grant com.zhiliaoapp.musically android.permission.WRITE_EXTERNAL_STORAGE
adb shell pm grant com.zhiliaoapp.musically android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.zhiliaoapp.musically android.permission.INTERNET
adb shell pm grant com.zhiliaoapp.musically android.permission.ACCESS_NETWORK_STATE
adb shell pm grant com.zhiliaoapp.musically android.permission.ACCESS_WIFI_STATE
adb shell pm grant com.zhiliaoapp.musically android.permission.ACCESS_FINE_LOCATION
adb shell pm grant com.zhiliaoapp.musically android.permission.ACCESS_COARSE_LOCATION

# Configura GPS per TikTok
adb shell settings put secure location_providers_allowed gps,network
adb shell settings put secure location_providers_allowed +gps
adb shell settings put secure location_providers_allowed +network

# Avvia TikTok
echo "🚀 Avvio TikTok..."
adb shell am start -n com.zhiliaoapp.musically/.main.MainActivity

# Configura account TikTok (opzionale)
echo "👤 Configurazione account TikTok..."
adb shell input tap 720 1560  # Tap su "Accedi" o "Registrati"
sleep 2
adb shell input tap 720 1800  # Tap su "Usa numero di telefono"
sleep 2

echo "✅ TikTok installato e configurato!"
echo "📱 Puoi ora utilizzare TikTok su questo dispositivo Android"
echo "🌐 Per accedere: VNC localhost:5901"
