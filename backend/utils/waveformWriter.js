const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { stringify } = require('csv-stringify/sync');

const s3Params = { region: process.env.AWS_REGION || 'eu-north-1' };
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  s3Params.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  };
}
const s3Client = new S3Client(s3Params);

const getWaveformsBucket = () => process.env.AWS_S3_WAVEFORMS_BUCKET || 'flexio-smart-waveforms';

/**
 * Uploads a file buffer to S3.
 */
async function uploadToS3(key, body, contentType) {
  const command = new PutObjectCommand({
    Bucket: getWaveformsBucket(),
    Key: key,
    Body: body,
    ContentType: contentType,
  });
  await s3Client.send(command);
}

/**
 * Flushes a completed session's in-memory buffer to S3 as CSV/JSON files.
 * @param {string} sessionId
 * @param {object} buffer { patientId, emg: [], imu: [], events: [] }
 * @returns {Promise<string>} The S3 key prefix where files were stored
 */
async function flushSessionToS3(sessionId, buffer) {
  if (!buffer || !buffer.patientId) {
    throw new Error('Invalid buffer data provided to flushSessionToS3');
  }

  const prefix = `sessions/${buffer.patientId}/${sessionId}/`;

  // 1. Process EMG to CSV
  // Expected shape per msg: { ts: 123, deviceId, sensors: [{ ch: 'emg1', samples: [...] }] }
  // We flatten this to: timestamp_ms, channel, value
  const emgRows = [];
  emgRows.push(['timestamp_ms', 'emg1', 'emg2', 'on1', 'on2']); // Header

  for (const msg of buffer.emg) {
    if (!msg.sensors || !Array.isArray(msg.sensors)) continue;
    
    const baseTs = msg.ts;
    const emg1Sensor = msg.sensors.find(s => s.ch === 'emg1' || s.ch === 'emg_upper');
    const emg2Sensor = msg.sensors.find(s => s.ch === 'emg2' || s.ch === 'emg_lower');
    const on1Sensor = msg.sensors.find(s => s.ch === 'on1');
    const on2Sensor = msg.sensors.find(s => s.ch === 'on2');
    
    const emg1Samples = emg1Sensor && Array.isArray(emg1Sensor.samples) ? emg1Sensor.samples : [];
    const emg2Samples = emg2Sensor && Array.isArray(emg2Sensor.samples) ? emg2Sensor.samples : [];
    const on1Samples = on1Sensor && Array.isArray(on1Sensor.samples) ? on1Sensor.samples : [];
    const on2Samples = on2Sensor && Array.isArray(on2Sensor.samples) ? on2Sensor.samples : [];
    
    const maxLen = Math.max(emg1Samples.length, emg2Samples.length, on1Samples.length, on2Samples.length);
    for (let i = 0; i < maxLen; i++) {
      emgRows.push([
        baseTs + (i * 20),
        emg1Samples[i] !== undefined ? emg1Samples[i] : '',
        emg2Samples[i] !== undefined ? emg2Samples[i] : '',
        on1Samples[i] !== undefined ? on1Samples[i] : '',
        on2Samples[i] !== undefined ? on2Samples[i] : '',
      ]);
    }
  }

  // 2. Process IMU to CSV
  // Expected shape: { ts, deviceId, samples: [{ kneeAngle: 23, thighGravity: [x,y,z], shinGravity: [x,y,z] }] }
  const imuRows = [];
  imuRows.push([
    'timestamp_ms', 
    'ax1', 'ay1', 'az1', 'gx1', 'gy1', 'gz1',
    'ax2', 'ay2', 'az2', 'gx2', 'gy2', 'gz2'
  ]); // Header

  for (const msg of buffer.imu) {
    if (!msg.samples || !Array.isArray(msg.samples)) continue;

    const baseTs = msg.ts;
    msg.samples.forEach((sample, i) => {
      const tg = sample.thighGravity || [0,0,0];
      const tgy = sample.thighGyro || [0,0,0];
      const sg = sample.shinGravity || [0,0,0];
      const sgy = sample.shinGyro || [0,0,0];
      imuRows.push([
        baseTs + (i * 20), 
        tg[0], tg[1], tg[2], tgy[0], tgy[1], tgy[2],
        sg[0], sg[1], sg[2], sgy[0], sgy[1], sgy[2]
      ]);
    });
  }

  // Generate CSV strings
  const emgCsv = stringify(emgRows);
  const imuCsv = stringify(imuRows);
  const eventsJson = JSON.stringify(buffer.events || [], null, 2);

  // Upload concurrently
  const uploadPromises = [
    uploadToS3(`${prefix}emg.csv`, emgCsv, 'text/csv'),
    uploadToS3(`${prefix}imu.csv`, imuCsv, 'text/csv'),
    uploadToS3(`${prefix}events.json`, eventsJson, 'application/json')
  ];

  await Promise.all(uploadPromises);
  
  return prefix;
}

module.exports = {
  flushSessionToS3
};
