const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const path = require('path');
const automationEngine = require('./automation/automation-engine');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));

// Configurazione dispositivi Android
const androidDevices = {
    device1: {
        id: 1,
        name: "Android 1",
        adbPort: 5555,
        webPort: 8080,
        vncPort: 5901,
        status: "offline",
        ip: "172.20.1.10"
    },
    device2: {
        id: 2,
        name: "Android 2", 
        adbPort: 5556,
        webPort: 8081,
        vncPort: 5902,
        status: "offline",
        ip: "172.20.2.10"
    },
    device3: {
        id: 3,
        name: "Android 3",
        adbPort: 5557,
        webPort: 8082,
        vncPort: 5903,
        status: "offline",
        ip: "172.20.3.10"
    }
};

// Funzione per eseguire comandi ADB
function executeAdbCommand(deviceId, command) {
    return new Promise((resolve, reject) => {
        const device = androidDevices[`device${deviceId}`];
        if (!device) {
            reject(new Error(`Dispositivo ${deviceId} non trovato`));
            return;
        }

        const fullCommand = `adb -s localhost:${device.adbPort} ${command}`;
        console.log(`Eseguendo: ${fullCommand}`);
        
        exec(fullCommand, (error, stdout, stderr) => {
            if (error) {
                console.error(`Errore ADB: ${error}`);
                reject(error);
            } else {
                console.log(`Output ADB: ${stdout}`);
                resolve(stdout);
            }
        });
    });
}

// Funzione per verificare stato dispositivi
async function checkDeviceStatus() {
    for (const [key, device] of Object.entries(androidDevices)) {
        try {
            const result = await executeAdbCommand(device.id, "get-state");
            device.status = result.trim() === "device" ? "online" : "offline";
        } catch (error) {
            device.status = "offline";
        }
    }
    return androidDevices;
}

// API Routes
app.get('/api/devices', async (req, res) => {
    const devices = await checkDeviceStatus();
    res.json(devices);
});

app.post('/api/device/:id/action', async (req, res) => {
    const deviceId = req.params.id;
    const { action, params } = req.body;
    
    try {
        let result;
        
        switch (action) {
            case 'tap':
                result = await executeAdbCommand(deviceId, `shell input tap ${params.x} ${params.y}`);
                break;
            case 'swipe':
                result = await executeAdbCommand(deviceId, `shell input swipe ${params.x1} ${params.y1} ${params.x2} ${params.y2} ${params.duration || 300}`);
                break;
            case 'text':
                result = await executeAdbCommand(deviceId, `shell input text "${params.text}"`);
                break;
            case 'key':
                result = await executeAdbCommand(deviceId, `shell input keyevent ${params.keycode}`);
                break;
            case 'screenshot':
                result = await executeAdbCommand(deviceId, `shell screencap -p /sdcard/screenshot.png`);
                // Trasferisci screenshot
                await executeAdbCommand(deviceId, `pull /sdcard/screenshot.png ./public/screenshots/device${deviceId}_screenshot.png`);
                result = `/screenshots/device${deviceId}_screenshot.png`;
                break;
            case 'install':
                result = await executeAdbCommand(deviceId, `install ${params.apkPath}`);
                break;
            case 'uninstall':
                result = await executeAdbCommand(deviceId, `uninstall ${params.packageName}`);
                break;
            case 'launch':
                result = await executeAdbCommand(deviceId, `shell am start -n ${params.packageName}/${params.activityName}`);
                break;
            default:
                throw new Error(`Azione non supportata: ${action}`);
        }
        
        res.json({ success: true, result });
        
        // Invia aggiornamento via WebSocket
        io.emit('deviceAction', {
            deviceId,
            action,
            result,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error(`Errore azione dispositivo ${deviceId}:`, error);
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

app.post('/api/automation/start', async (req, res) => {
    const { deviceId, script } = req.body;
    
    try {
        // Avvia script di automazione
        const result = await automationEngine.start(deviceId, script);
        
        res.json({ success: true, result });
        
        // Invia aggiornamento via WebSocket
        io.emit('automationStarted', {
            deviceId,
            script,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error(`Errore automazione dispositivo ${deviceId}:`, error);
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

app.post('/api/automation/stop', async (req, res) => {
    const { deviceId } = req.body;
    
    try {
        const stopped = automationEngine.stop(deviceId);
        
        res.json({ success: true, stopped });
        
        // Invia aggiornamento via WebSocket
        io.emit('automationStopped', {
            deviceId,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error(`Errore arresto automazione dispositivo ${deviceId}:`, error);
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

app.get('/api/automation/status', (req, res) => {
    const status = automationEngine.getStatus();
    res.json(status);
});

// WebSocket connection
io.on('connection', (socket) => {
    console.log('Client connesso:', socket.id);
    
    // Invia stato iniziale
    socket.emit('devicesStatus', androidDevices);
    
    // Gestisci richieste di aggiornamento stato
    socket.on('requestStatus', async () => {
        const devices = await checkDeviceStatus();
        socket.emit('devicesStatus', devices);
    });
    
    socket.on('disconnect', () => {
        console.log('Client disconnesso:', socket.id);
    });
    
    // Eventi automazione
    automationEngine.on('log', (data) => {
        socket.emit('automationLog', data);
    });
    
    automationEngine.on('automationStarted', (data) => {
        socket.emit('automationStarted', data);
    });
    
    automationEngine.on('automationCompleted', (data) => {
        socket.emit('automationCompleted', data);
    });
    
    automationEngine.on('automationError', (data) => {
        socket.emit('automationError', data);
    });
});

// Avvia server
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Pannello di controllo avviato su porta ${PORT}`);
    console.log(`🌐 Accesso: http://localhost:${PORT}`);
    
    // Crea directory per screenshot
    const fs = require('fs');
    if (!fs.existsSync('./public/screenshots')) {
        fs.mkdirSync('./public/screenshots', { recursive: true });
    }
    
    // Verifica stato dispositivi ogni 30 secondi
    setInterval(async () => {
        const devices = await checkDeviceStatus();
        io.emit('devicesStatus', devices);
    }, 30000);
});
