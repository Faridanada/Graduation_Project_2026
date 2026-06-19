const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { stringify } = require('csv-stringify/sync');

const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'eu-north-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  }
});

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
  emgRows.push(['timestamp_ms', 'channel', 'value']); // Header

  for (const msg of buffer.emg) {
    if (!msg.sensors || !Array.isArray(msg.sensors)) continue;
    
    // We assume 50Hz, meaning each sample in the array is 20ms apart from the start `ts`.
    // For simplicity, we just assign the same `ts` or increment by 20.
    const baseTs = msg.ts;
    for (const sensor of msg.sensors) {
      if (Array.isArray(sensor.samples)) {
        sensor.samples.forEach((val, i) => {
          emgRows.push([baseTs + (i * 20), sensor.ch, val]);
        });
      }
    }
  }

  // 2. Process IMU to CSV
  // Expected shape: { ts, deviceId, samples: [{ kneeAngle: 23, thighGravity: [x,y,z], shinGravity: [x,y,z] }] }
  const imuRows = [];
  imuRows.push([
    'timestamp_ms', 'kneeAngle', 
    'thighGravity_x', 'thighGravity_y', 'thighGravity_z',
    'shinGravity_x', 'shinGravity_y', 'shinGravity_z'
  ]); // Header

  for (const msg of buffer.imu) {
    if (!msg.samples || !Array.isArray(msg.samples)) continue;

    const baseTs = msg.ts;
    msg.samples.forEach((sample, i) => {
      const tg = sample.thighGravity || [0,0,0];
      const sg = sample.shinGravity || [0,0,0];
      imuRows.push([
        baseTs + (i * 20), 
        sample.kneeAngle || 0,
        tg[0], tg[1], tg[2],
        sg[0], sg[1], sg[2]
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
