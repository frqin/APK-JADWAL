const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

// Log saat server mulai
console.log('Server WebSocket sedang berjalan di port 8080');

// Hitung jumlah klien yang terhubung
let connectedClients = 0;

wss.on('connection', (ws) => {
    connectedClients++;
    console.log(`Klien terhubung. Total klien: ${connectedClients}`);

    ws.on('message', (message) => {
        try {
            // Dekode pesan
            const messageString = Buffer.from(message).toString('utf8');

            // Log pesan yang diterima
            console.log('\nPesan baru diterima:');
            console.log('-------------------------');
            console.log('Isi pesan:', messageString);
            console.log('Waktu:', new Date().toLocaleTimeString());
            console.log('-------------------------\n');

            // Broadcast pesan ke semua klien
            wss.clients.forEach((client) => {
                if (client !== ws && client.readyState === WebSocket.OPEN) {
                    client.send(messageString);
                }
            });
        } catch (error) {
            console.error('Error memproses pesan:', error);
        }
    });

    ws.on('error', (error) => {
        console.error('Error WebSocket:', error);
    });

    ws.on('close', () => {
        connectedClients--;
        console.log(`Klien terputus. Total klien: ${connectedClients}`);
    });
});

// Error handling untuk server
wss.on('error', (error) => {
    console.error('Error server:', error);
});

// Cek koneksi setiap 30 detik
setInterval(() => {
    console.log(`Status server: Online | Klien terhubung: ${connectedClients}`);
}, 30000);