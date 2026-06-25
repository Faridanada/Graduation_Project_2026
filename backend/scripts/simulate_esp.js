const mqtt = require('mqtt');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');
const path = require('path');

// Auto-load environment variables from the parent backend folder .env file
require('dotenv').config({ path: path.join(__dirname, '../.env') });

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
    default: process.env.MQTT_URL || process.env.MQTT_BROKER_URL || 'mqtt://127.0.0.1:1883'
  })
  .option('username', {
    alias: 'u',
    type: 'string',
    description: 'MQTT Broker Username',
    default: process.env.MQTT_USERNAME // Fallback to backend .env
  })
  .option('password', {
    alias: 'p',
    type: 'string',
    description: 'MQTT Broker Password',
    default: process.env.MQTT_PASSWORD // Fallback to backend .env
  })
  .parse();

const deviceId = argv.device;
const rate = argv.rate;
const brokerUrl = argv.host;

const options = {
  clientId: `sim_esp_${Math.random().toString(16).slice(3)}`,
  clean: true,
  connectTimeout: 4000,
  reconnectPeriod: 5000,
};

// Force assign credentials if found in flags or .env
if (argv.username && argv.password) {
  options.username = argv.username.trim();
  options.password = argv.password.trim();
}

// DEBUG LOG: Let's see exactly what Node is attempting to send
console.log(`[DEBUG] Attempting connection...`);
console.log(`[DEBUG] Target Host: ${brokerUrl}`);
console.log(`[DEBUG] Sending Username: "${options.username || 'NONE'}"`);
console.log(`[DEBUG] Sending Password Length: ${options.password ? options.password.length : 0} characters`);

console.log(`Connecting to MQTT broker at ${brokerUrl}...`);
const client = mqtt.connect(brokerUrl, options);

let t = 0;

client.on('connect', () => {
  console.log(`\n✅ Connected successfully!`);
  console.log(`Simulating ${deviceId} bundle channel mapping at ${rate}ms.`);

  setInterval(() => {
    const angleThigh = Math.sin(t) * 45;
    const angleCalf = Math.sin(t) * 90;

    const emg1 = Math.abs(Math.sin(t * 5) * 50);
    const emg2 = Math.abs(Math.cos(t * 5) * 50);

    const bundle = {
      ts: Date.now(),
      deviceId: deviceId,
      emg1: emg1,
      emg2: emg2,
      on1: 1,
      on2: 1,
      ax1: 0,
      ay1: Math.sin(angleThigh * Math.PI / 180),
      az1: Math.cos(angleThigh * Math.PI / 180),
      gx1: 0,
      gy1: 0,
      gz1: 0,
      ax2: 0,
      ay2: Math.sin(angleCalf * Math.PI / 180),
      az2: Math.cos(angleCalf * Math.PI / 180),
      gx2: 0,
      gy2: 0,
      gz2: 0
    };

    const topic = `flexio/${deviceId}/bundle`;
    client.publish(topic, JSON.stringify(bundle));

    t += (rate / 1000);

  }, rate);
});

client.on('error', (err) => {
  console.error('\n❌ MQTT error:', err.message);
  process.exit(1);
});