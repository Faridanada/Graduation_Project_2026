const mqtt = require('mqtt');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

const argv = yargs(hideBin(process.argv))
  .option('device', {
    alias: 'd',
    type: 'string',
    description: 'Device ID',
    default: 'ESP32_Test'
  })
  .option('rate', {
    alias: 'r',
    type: 'number',
    description: 'Message rate (ms)',
    default: 20
  })
  .option('host', {
    alias: 'h',
    type: 'string',
    description: 'MQTT Broker URL',
    default: process.env.MQTT_BROKER_URL || 'mqtt://127.0.0.1:1883'
  })
  .option('username', {
    alias: 'u',
    type: 'string',
    description: 'MQTT Broker Username'
  })
  .option('password', {
    alias: 'p',
    type: 'string',
    description: 'MQTT Broker Password'
  })
  .parse();

const deviceId = argv.device;
const rate = argv.rate;
let brokerUrl = argv.host;

// URL-based credential injection to completely bypass client authorization bugs
if (argv.username && argv.password) {
  const credentials = `${encodeURIComponent(argv.username)}:${encodeURIComponent(argv.password)}`;
  brokerUrl = brokerUrl.replace('mqtt://', `mqtt://${credentials}@`);
}

console.log(`Connecting to broker...`);
const client = mqtt.connect(brokerUrl);

let t = 0;

client.on('connect', () => {
  console.log(`Connected successfully! Simulating ${deviceId} bundle channel mapping at ${rate}ms.`);

  setInterval(() => {
    // Generate sine waves for leg trajectory tracking
    const angleThigh = Math.sin(t) * 45; // -45 to 45
    const angleCalf = Math.sin(t) * 90;  // -90 to 90

    // Simulate EMG activity (spikes above 20 to test Flutter's dynamic warning banner)
    const emg1 = Math.abs(Math.sin(t * 5) * 50);
    const emg2 = Math.abs(Math.cos(t * 5) * 50);

    // FLATTENED SCHEMA - Matches exactly what MqttService.js expects
    const bundle = {
      ts: Date.now(),
      deviceId: deviceId,
      emg1: emg1,
      emg2: emg2,
      on1: 1,
      on2: 1,
      // Thigh IMU (IMU 1)
      ax1: 0,
      ay1: Math.sin(angleThigh * Math.PI / 180),
      az1: Math.cos(angleThigh * Math.PI / 180),
      gx1: 0,
      gy1: 0,
      gz1: 0,
      // Calf IMU (IMU 2)
      ax2: 0,
      ay2: Math.sin(angleCalf * Math.PI / 180),
      az2: Math.cos(angleCalf * Math.PI / 180),
      gx2: 0,
      gy2: 0,
      gz2: 0
    };

    const topic = `flexio/${deviceId}/bundle`;
    client.publish(topic, JSON.stringify(bundle));

    t += (rate / 1000); // increment dt

  }, rate);
});

client.on('error', (err) => {
  console.error('MQTT error:', err);
  process.exit(1);
});