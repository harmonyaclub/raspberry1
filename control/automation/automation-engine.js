const { exec } = require('child_process');
const EventEmitter = require('events');

class AutomationEngine extends EventEmitter {
    constructor() {
        super();
        this.runningTasks = new Map();
        this.scripts = {
            basic_automation: this.basicAutomation.bind(this),
            app_testing: this.appTesting.bind(this),
            performance_test: this.performanceTest.bind(this)
        };
    }

    async start(deviceId, scriptName) {
        if (this.runningTasks.has(deviceId)) {
            throw new Error(`Automazione già in esecuzione per dispositivo ${deviceId}`);
        }

        const task = {
            deviceId,
            scriptName,
            startTime: new Date(),
            status: 'running'
        };

        this.runningTasks.set(deviceId, task);
        this.emit('automationStarted', task);

        try {
            if (this.scripts[scriptName]) {
                await this.scripts[scriptName](deviceId);
            } else {
                // Script personalizzato
                await this.executeCustomScript(deviceId, scriptName);
            }
        } catch (error) {
            this.emit('automationError', { deviceId, error: error.message });
            throw error;
        } finally {
            this.runningTasks.delete(deviceId);
            this.emit('automationCompleted', { deviceId, scriptName });
        }
    }

    async executeAdbCommand(deviceId, command) {
        return new Promise((resolve, reject) => {
            const device = this.getDeviceConfig(deviceId);
            const fullCommand = `adb -s localhost:${device.adbPort} ${command}`;
            
            exec(fullCommand, (error, stdout, stderr) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(stdout);
                }
            });
        });
    }

    getDeviceConfig(deviceId) {
        const configs = {
            1: { adbPort: 5555, name: 'Android 1' },
            2: { adbPort: 5556, name: 'Android 2' },
            3: { adbPort: 5557, name: 'Android 3' }
        };
        return configs[deviceId];
    }

    async basicAutomation(deviceId) {
        this.emit('log', { deviceId, message: 'Avvio automazione base...', level: 'info' });
        
        // Test di base: tap, swipe, input
        await this.delay(2000);
        
        // Tap al centro dello schermo
        await this.executeAdbCommand(deviceId, 'shell input tap 500 500');
        this.emit('log', { deviceId, message: 'Tap eseguito al centro schermo', level: 'info' });
        
        await this.delay(1000);
        
        // Swipe da sinistra a destra
        await this.executeAdbCommand(deviceId, 'shell input swipe 100 500 900 500 300');
        this.emit('log', { deviceId, message: 'Swipe eseguito', level: 'info' });
        
        await this.delay(1000);
        
        // Input testo
        await this.executeAdbCommand(deviceId, 'shell input text "Hello Android!"');
        this.emit('log', { deviceId, message: 'Testo inserito', level: 'info' });
        
        await this.delay(1000);
        
        // Screenshot finale
        await this.executeAdbCommand(deviceId, 'shell screencap -p /sdcard/automation_screenshot.png');
        this.emit('log', { deviceId, message: 'Screenshot acquisito', level: 'info' });
        
        this.emit('log', { deviceId, message: 'Automazione base completata', level: 'success' });
    }

    async appTesting(deviceId) {
        this.emit('log', { deviceId, message: 'Avvio test applicazioni...', level: 'info' });
        
        // Lista app da testare
        const apps = [
            { package: 'com.android.settings', activity: '.Settings' },
            { package: 'com.android.calculator2', activity: '.Calculator' },
            { package: 'com.android.calendar', activity: '.AllInOneActivity' }
        ];
        
        for (const app of apps) {
            try {
                this.emit('log', { deviceId, message: `Test app: ${app.package}`, level: 'info' });
                
                // Avvia app
                await this.executeAdbCommand(deviceId, `shell am start -n ${app.package}/${app.activity}`);
                await this.delay(3000);
                
                // Test interazioni base
                await this.executeAdbCommand(deviceId, 'shell input tap 500 500');
                await this.delay(1000);
                
                // Torna alla home
                await this.executeAdbCommand(deviceId, 'shell input keyevent KEYCODE_HOME');
                await this.delay(2000);
                
                this.emit('log', { deviceId, message: `App ${app.package} testata con successo`, level: 'success' });
                
            } catch (error) {
                this.emit('log', { deviceId, message: `Errore test app ${app.package}: ${error.message}`, level: 'error' });
            }
        }
        
        this.emit('log', { deviceId, message: 'Test applicazioni completato', level: 'success' });
    }

    async performanceTest(deviceId) {
        this.emit('log', { deviceId, message: 'Avvio test performance...', level: 'info' });
        
        const iterations = 10;
        
        for (let i = 0; i < iterations; i++) {
            this.emit('log', { deviceId, message: `Iterazione ${i + 1}/${iterations}`, level: 'info' });
            
            // Test CPU intensivo
            const startTime = Date.now();
            
            // Esegui operazioni multiple
            await Promise.all([
                this.executeAdbCommand(deviceId, 'shell input tap 200 200'),
                this.executeAdbCommand(deviceId, 'shell input tap 400 400'),
                this.executeAdbCommand(deviceId, 'shell input tap 600 600'),
                this.executeAdbCommand(deviceId, 'shell input tap 800 800')
            ]);
            
            const endTime = Date.now();
            const duration = endTime - startTime;
            
            this.emit('log', { 
                deviceId, 
                message: `Iterazione ${i + 1} completata in ${duration}ms`, 
                level: 'info' 
            });
            
            await this.delay(1000);
        }
        
        // Test memoria
        this.emit('log', { deviceId, message: 'Test utilizzo memoria...', level: 'info' });
        const memInfo = await this.executeAdbCommand(deviceId, 'shell cat /proc/meminfo');
        this.emit('log', { deviceId, message: `Memoria: ${memInfo.split('\n')[0]}`, level: 'info' });
        
        this.emit('log', { deviceId, message: 'Test performance completato', level: 'success' });
    }

    async executeCustomScript(deviceId, script) {
        this.emit('log', { deviceId, message: 'Esecuzione script personalizzato...', level: 'info' });
        
        // Parse e esegui script personalizzato
        const lines = script.split('\n').filter(line => line.trim());
        
        for (const line of lines) {
            const trimmedLine = line.trim();
            if (trimmedLine.startsWith('#')) continue; // Commento
            
            try {
                if (trimmedLine.startsWith('tap ')) {
                    const coords = trimmedLine.split(' ').slice(1);
                    if (coords.length >= 2) {
                        await this.executeAdbCommand(deviceId, `shell input tap ${coords[0]} ${coords[1]}`);
                        this.emit('log', { deviceId, message: `Tap: ${coords[0]}, ${coords[1]}`, level: 'info' });
                    }
                } else if (trimmedLine.startsWith('swipe ')) {
                    const coords = trimmedLine.split(' ').slice(1);
                    if (coords.length >= 4) {
                        await this.executeAdbCommand(deviceId, `shell input swipe ${coords[0]} ${coords[1]} ${coords[2]} ${coords[3]} 300`);
                        this.emit('log', { deviceId, message: `Swipe: ${coords[0]}, ${coords[1]} -> ${coords[2]}, ${coords[3]}`, level: 'info' });
                    }
                } else if (trimmedLine.startsWith('text ')) {
                    const text = trimmedLine.substring(5);
                    await this.executeAdbCommand(deviceId, `shell input text "${text}"`);
                    this.emit('log', { deviceId, message: `Testo: ${text}`, level: 'info' });
                } else if (trimmedLine.startsWith('key ')) {
                    const keycode = trimmedLine.split(' ')[1];
                    await this.executeAdbCommand(deviceId, `shell input keyevent ${keycode}`);
                    this.emit('log', { deviceId, message: `Tasto: ${keycode}`, level: 'info' });
                } else if (trimmedLine.startsWith('wait ')) {
                    const ms = parseInt(trimmedLine.split(' ')[1]) || 1000;
                    await this.delay(ms);
                    this.emit('log', { deviceId, message: `Attesa: ${ms}ms`, level: 'info' });
                } else if (trimmedLine.startsWith('screenshot')) {
                    await this.executeAdbCommand(deviceId, 'shell screencap -p /sdcard/custom_screenshot.png');
                    this.emit('log', { deviceId, message: 'Screenshot acquisito', level: 'info' });
                }
                
                await this.delay(500); // Pausa tra comandi
                
            } catch (error) {
                this.emit('log', { deviceId, message: `Errore comando "${trimmedLine}": ${error.message}`, level: 'error' });
            }
        }
        
        this.emit('log', { deviceId, message: 'Script personalizzato completato', level: 'success' });
    }

    async delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    stop(deviceId) {
        if (this.runningTasks.has(deviceId)) {
            this.runningTasks.delete(deviceId);
            this.emit('automationStopped', { deviceId });
            return true;
        }
        return false;
    }

    getStatus() {
        return {
            runningTasks: Array.from(this.runningTasks.values()),
            availableScripts: Object.keys(this.scripts)
        };
    }
}

module.exports = new AutomationEngine();
