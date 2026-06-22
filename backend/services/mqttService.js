const mqtt = require('mqtt');
const dbService = require('./dbService');
const sessionBuffer = require('./sessionBuffer');
const liveSocket = require('./liveSocket');

class MqttService {
  constructor() {
    this.client = null;
    this.deviceCache = new Map(); // deviceId -> { patientId, lastFetched }
    this.CACHE_TTL = 60000; // 60 seconds
  }

  init() {
    const brokerUrl = process.env.MQTT_URL || 'mqtt://localhost:1883';
    
    const options = {
      clientId: `backend_${Math.random().toString(16).slice(3)}`,
      clean: true,
      connectTimeout: 4000,
      reconnectPeriod: 5000, // Important for graceful reconnect
    };

    if (process.env.MQTT_USERNAME && process.env.MQTT_PASSWORD) {
      options.username = process.env.MQTT_USERNAME;
      options.password = process.env.MQTT_PASSWORD;
    }

    console.log(`[MQTT] Connecting to broker at ${brokerUrl}...`);
    this.client = mqtt.connect(brokerUrl, options);

    // Graceful error handling - DO NOT CRASH
    this.client.on('error', (err) => {
      console.warn(`[MQTT] Connection error: ${err.message}. Will keep retrying...`);
    });

    this.client.on('connect', () => {
      console.log(`[MQTT] Connected successfully to ${brokerUrl}`);
      // Subscribe to topics
      this.client.subscribe('flexio/+/emg');
      this.client.subscribe('flexio/+/imu');
      this.client.subscribe('flexio/+/stream'); // New 16-column stream format
      this.client.subscribe('flexio/+/keyword');
      this.client.subscribe('flexio/+/heartbeat');
    });

    this.client.on('offline', () => {
      console.warn(`[MQTT] Offline. Attempting to reconnect...`);
    });

    this.client.on('reconnect', () => {
      console.log(`[MQTT] Reconnecting...`);
    });

    this.client.on('message', async (topic, message) => {
      try {
        const strMsg = message.toString().trim();
        
        // Handle raw 16-column stream format
        if (topic.endsWith('/stream')) {
          await this.handleStreamString(topic, strMsg);
          return;
        }

        // Handle structured JSON payloads (legacy format or structured commands)
        if (strMsg.startsWith('{')) {
          const payload = JSON.parse(strMsg);
          await this.handleMessage(topic, payload);
        }
      } catch (err) {
        console.warn(`[MQTT] Invalid payload on topic ${topic}: ${err.message}`);
      }
    });
  }

  async getPatientIdForDevice(deviceId) {
    if (!deviceId) return null;

    const cached = this.deviceCache.get(deviceId);
    if (cached && (Date.now() - cached.lastFetched) < this.CACHE_TTL) {
      return cached.patientId;
    }

    try {
      const device = await dbService.getDeviceById(deviceId);
      if (device && device.patientId) {
        this.deviceCache.set(deviceId, { patientId: device.patientId, lastFetched: Date.now() });
        return device.patientId;
      }
    } catch (err) {
      console.error(`[MQTT] Error fetching device ${deviceId}:`, err);
    }
    return null;
  }

  async handleMessage(topic, payload) {
    // Topic format: flexio/{deviceId}/{kind}
    const parts = topic.split('/');
    if (parts.length !== 3 || parts[0] !== 'flexio') return;

    const deviceId = parts[1];
    const kind = parts[2]; // 'emg', 'imu', 'keyword', 'heartbeat'

    if (!payload.ts || !payload.deviceId || payload.deviceId !== deviceId) {
      console.warn(`[MQTT] Malformed payload or deviceId mismatch on ${topic}`);
      return;
    }

    if (kind === 'heartbeat') {
      // Just alive ping, might update lastSeenAt in DB in the future.
      return;
    }

    sessionBuffer.addReading(deviceId, kind, payload);

    // Determine target session
    const patientId = await this.getPatientIdForDevice(deviceId);
    if (!patientId) {
      // Unregistered device or unable to map
      return;
    }

    // 1. Add to active session buffer
    let normalizedKind = kind;
    if (kind === 'keyword') normalizedKind = 'event';
    sessionBuffer.addReading(deviceId, normalizedKind, payload);

    // 2. Broadcast to live websocket clients (doctors watching this session)
    const activeSession = sessionBuffer.getActiveSessionForDevice(deviceId);
    if (activeSession) {
      liveSocket.broadcast(activeSession.sessionId, { kind: normalizedKind, data: payload });
    }
  }

  async handleStreamString(topic, strMsg) {
    const parts = topic.split('/');
    if (parts.length !== 3 || parts[0] !== 'flexio') return;
    const deviceId = parts[1];

    const lines = strMsg.split('\n');
    
    const emgSamples1 = [];
    const emgSamples2 = [];
    const imuSamples = [];

    for (const line of lines) {
      if (!line.trim()) continue;
      const cols = line.trim().split(/\s+/).map(Number);
      if (cols.length < 16) continue;

      emgSamples1.push(cols[0]);
      emgSamples2.push(cols[1]);

      imuSamples.push({
        thighGravity: [cols[4], cols[5], cols[6]],
        thighGyro: [cols[7], cols[8], cols[9]],
        shinGravity: [cols[10], cols[11], cols[12]],
        shinGyro: [cols[13], cols[14], cols[15]]
      });
    }

    if (emgSamples1.length === 0) return;

    // The ESP does not send a timestamp; we must append the arrival time
    const ts = Date.now();

    const emgPayload = {
      ts,
      deviceId,
      sensors: [
        { ch: 'emg1', samples: emgSamples1 },
        { ch: 'emg2', samples: emgSamples2 }
      ]
    };

    const imuPayload = {
      ts,
      deviceId,
      samples: imuSamples
    };

    sessionBuffer.addReading(deviceId, 'emg', emgPayload);
    sessionBuffer.addReading(deviceId, 'imu', imuPayload);

    // Broadcast to live websocket clients
    const activeSession = sessionBuffer.getActiveSessionForDevice(deviceId);
    if (activeSession) {
      liveSocket.broadcast(activeSession.sessionId, { kind: 'emg', data: emgPayload });
      liveSocket.broadcast(activeSession.sessionId, { kind: 'imu', data: imuPayload });
    }
  }
}

module.exports = new MqttService();
