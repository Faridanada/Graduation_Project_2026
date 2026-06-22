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
    // If it's the old nested format, skip it to keep CSV clean
    if (msg.sensors && Array.isArray(msg.sensors)) {
      console.warn(`[waveformWriter] Skipping legacy nested EMG reading at ts=${msg.ts}`);
      continue;
    }

    emgRows.push([
      msg.ts,
      msg.emg1 !== undefined ? msg.emg1 : NaN,
      msg.emg2 !== undefined ? msg.emg2 : NaN,
      msg.on1 !== undefined && msg.on1 !== null ? msg.on1 : NaN,
      msg.on2 !== undefined && msg.on2 !== null ? msg.on2 : NaN,
    ]);
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
    // If it's the old nested format, skip it
    if (msg.samples && Array.isArray(msg.samples)) {
      console.warn(`[waveformWriter] Skipping legacy nested IMU reading at ts=${msg.ts}`);
      continue;
    }

    imuRows.push([
      msg.ts, 
      msg.ax1 !== undefined ? msg.ax1 : NaN,
      msg.ay1 !== undefined ? msg.ay1 : NaN,
      msg.az1 !== undefined ? msg.az1 : NaN,
      msg.gx1 !== undefined ? msg.gx1 : NaN,
      msg.gy1 !== undefined ? msg.gy1 : NaN,
      msg.gz1 !== undefined ? msg.gz1 : NaN,
      msg.ax2 !== undefined ? msg.ax2 : NaN,
      msg.ay2 !== undefined ? msg.ay2 : NaN,
      msg.az2 !== undefined ? msg.az2 : NaN,
      msg.gx2 !== undefined ? msg.gx2 : NaN,
      msg.gy2 !== undefined ? msg.gy2 : NaN,
      msg.gz2 !== undefined ? msg.gz2 : NaN
    ]);
  }

  // Sort rows by timestamp ascending
  // The header is at index 0, so we slice and sort the rest
  const emgHeader = emgRows.shift();
  emgRows.sort((a, b) => a[0] - b[0]);
  emgRows.unshift(emgHeader);

  const imuHeader = imuRows.shift();
  imuRows.sort((a, b) => a[0] - b[0]);
  imuRows.unshift(imuHeader);

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
