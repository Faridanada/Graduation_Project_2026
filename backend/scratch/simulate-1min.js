const mqtt = require('mqtt');

// Connect directly to your DuckDNS broker
const client = mqtt.connect('mqtt://flexio-rehab.duckdns.org', {
  username: 'esp32_test',
  password: 'yomna123'
});

const DEVICE_ID = 'esp32_test_device';

client.on('connect', () => {
  console.log('✅ Connected to MQTT Broker!');
  console.log(`📡 Streaming 50Hz sensor data to flexio/${DEVICE_ID}/bundle for 1 minute...`);
  
  let count = 0;
  const totalPackets = 50 * 60; // 50Hz for 60 seconds = 3000 packets

  const interval = setInterval(() => {
    // Construct the exact 16-channel JSON payload your Node backend expects
    const payload = {
      ts: Date.now(),
      deviceId: DEVICE_ID,
      emg1: Number(Math.random().toFixed(4)),
      emg2: Number((Math.random() * 0.5).toFixed(4)),
      on1: 1, 
      on2: 1,
      ax1: 0.01, ay1: 0.02, az1: 0.98, gx1: 0.0, gy1: 0.0, gz1: 0.0,
      ax2: 0.01, ay2: 0.02, az2: 0.98, gx2: 0.0, gy2: 0.0, gz2: 0.0
    };

    client.publish(`flexio/${DEVICE_ID}/bundle`, JSON.stringify(payload));
    
    count++;
    
    // Print a progress update every second (every 50 packets)
    if (count % 50 === 0) {
      console.log(`⏳ Sent ${count} / ${totalPackets} packets...`);
    }

    if (count >= totalPackets) {
      clearInterval(interval);
      console.log('✅ Finished streaming 1 minute of data!');
      process.exit(0);
    }
  }, 20); // 20ms = 50Hz
});

client.on('error', (err) => {
  console.error('MQTT Error:', err.message);
  process.exit(1);
});
