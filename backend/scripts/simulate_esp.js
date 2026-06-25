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
  .parse();

const deviceId = argv.device;
const rate = argv.rate;
const brokerUrl = process.env.MQTT_BROKER_URL || 'mqtt://127.0.0.1:1883';

console.log(`Connecting to ${brokerUrl}...`);
const client = mqtt.connect(brokerUrl);

let t = 0;

client.on('connect', () => {
  console.log(`Connected to MQTT broker. Simulating ESP32 ${deviceId} at ${rate}ms.`);

  setInterval(() => {
    // Generate a sine wave for the IMU data to simulate a moving leg
    // 1 rad/s -> about 6 seconds per full cycle
    const angleThigh = Math.sin(t) * 45; // -45 to 45
    const angleCalf = Math.sin(t) * 90;  // -90 to 90

    const imu1 = {
      ax: 0,
      ay: Math.sin(angleThigh * Math.PI / 180),
      az: Math.cos(angleThigh * Math.PI / 180),
      gx: 0,
      gy: 0,
      gz: 0
    };

    const imu2 = {
      ax: 0,
      ay: Math.sin(angleCalf * Math.PI / 180),
      az: Math.cos(angleCalf * Math.PI / 180),
      gx: 0,
      gy: 0,
      gz: 0
    };

    const emg1 = Math.abs(Math.sin(t * 5) * 50); // Simulate some muscle activity
    const emg2 = Math.abs(Math.cos(t * 5) * 50);

    const bundle = {
      device_id: deviceId,
      timestamp: Date.now(),
      imu1,
      imu2,
      emg1,
      emg2,
      sys_cal: 3,
      gyro_cal: 3,
      accel_cal: 3,
      mag_cal: 3
    };

    const topic = `flexio/${deviceId}/bundle`;
    client.publish(topic, JSON.stringify(bundle));
    
    t += (rate / 1000); // increment time by dt in seconds

  }, rate);
});

client.on('error', (err) => {
  console.error('MQTT error:', err);
  process.exit(1);
});
