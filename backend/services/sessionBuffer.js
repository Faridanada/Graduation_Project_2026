const MAX_READINGS_PER_SESSION = 5000000; // ~100MB equivalent limit

class SessionBuffer {
  constructor() {
    this.sessions = new Map(); // sessionId -> bufferData
    this.deviceToSession = new Map(); // deviceId -> sessionId
  }

  /**
   * Starts a new session buffer for ingestion.
   */
  startSession(sessionId, patientId, exerciseId, deviceId) {
    if (this.deviceToSession.has(deviceId)) {
      const existingSessionId = this.deviceToSession.get(deviceId);
      console.warn(`[SessionBuffer] Device ${deviceId} already has an active session ${existingSessionId}. Overriding.`);
      this.abortSession(existingSessionId);
    }

    const sessionData = {
      sessionId,
      patientId,
      exerciseId,
      deviceId,
      emg: [],
      imu: [],
      events: [],
      startTime: Date.now(),
      lastSampleTime: null,
      sampleCount: 0
    };

    this.sessions.set(sessionId, sessionData);
    this.deviceToSession.set(deviceId, sessionId);
    console.log(`[SessionBuffer] Started session ${sessionId} for device ${deviceId}`);
  }

  /**
   * Adds a reading from the MQTT subscriber or the simulator.
   * @param {string} deviceId 
   * @param {string} kind 'emg' | 'imu' | 'event'
   * @param {object} payload 
   */
  addReading(deviceId, kind, payload) {
    const sessionId = this.deviceToSession.get(deviceId);
    if (!sessionId) {
      // It's normal for a device to stream data while no session is active, so we discard gracefully.
      return;
    }

    const session = this.sessions.get(sessionId);
    if (!session) return;

    if (session.sampleCount > MAX_READINGS_PER_SESSION) {
      console.warn(`[SessionBuffer] Session ${sessionId} exceeded max capacity (${MAX_READINGS_PER_SESSION}). Dropping reading.`);
      return;
    }

    if (kind === 'emg') {
      session.emg.push(payload);
    } else if (kind === 'imu') {
      session.imu.push(payload);
    } else if (kind === 'event') {
      session.events.push(payload);
    }

    session.sampleCount++;
    session.lastSampleTime = Date.now();
  }

  getActiveSessionForDevice(deviceId) {
    const sessionId = this.deviceToSession.get(deviceId);
    if (!sessionId) return null;
    return this.sessions.get(sessionId) || null;
  }

  /**
   * Ends a session and returns the buffered data for flush.
   */
  endSession(sessionId) {
    const session = this.sessions.get(sessionId);
    if (!session) {
      console.warn(`[SessionBuffer] Attempted to end non-existent session ${sessionId}`);
      return null;
    }

    this.deviceToSession.delete(session.deviceId);
    this.sessions.delete(sessionId);
    
    console.log(`[SessionBuffer] Ended session ${sessionId}. Total samples: ${session.sampleCount}`);
    return session;
  }

  /**
   * Aborts a session, discarding the buffer.
   */
  abortSession(sessionId) {
    const session = this.sessions.get(sessionId);
    if (session) {
      this.deviceToSession.delete(session.deviceId);
      this.sessions.delete(sessionId);
      console.log(`[SessionBuffer] Aborted session ${sessionId}`);
    }
  }

  /**
   * Test/dev only: Inject a fake reading into the buffer as if it came from MQTT.
   * Used for end-to-end testing without Mosquitto/hardware.
   */
  simulate(sessionId, kind, payload) {
    const session = this.sessions.get(sessionId);
    if (!session) {
      console.warn(`[SessionBuffer:simulate] No active session ${sessionId} to inject to`);
      return;
    }
    
    // Inject directly bypassing deviceId lookup since we have sessionId
    if (session.sampleCount > MAX_READINGS_PER_SESSION) return;

    if (kind === 'emg') session.emg.push(payload);
    else if (kind === 'imu') session.imu.push(payload);
    else if (kind === 'event') session.events.push(payload);

    session.sampleCount++;
    session.lastSampleTime = Date.now();
  }
}

// Export a singleton instance
module.exports = new SessionBuffer();
