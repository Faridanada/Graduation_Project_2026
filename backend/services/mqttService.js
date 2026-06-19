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
        const payload = JSON.parse(message.toString());
        await this.handleMessage(topic, payload);
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
}

module.exports = new MqttService();
