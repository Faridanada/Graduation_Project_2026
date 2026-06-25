const dbService = require('../services/dbService');
const sessionBuffer = require('../services/sessionBuffer');
const waveformWriter = require('../utils/waveformWriter');
const { getSignedReadUrl } = require('../utils/s3Service');
const { v4: uuidv4 } = require('uuid');
const { triggerReportGeneration } = require('../services/reportTrigger');
const getWaveformsBucket = () => process.env.AWS_S3_WAVEFORMS_BUCKET || 'flexio-smart-waveforms';

// ================= DEVICES =================

exports.registerDevice = async (req, res) => {
  try {
    const { deviceId, mqttUsername } = req.body;
    const patientId = req.user.id;

    if (!deviceId || !mqttUsername) {
      return res.status(400).json({ message: "deviceId and mqttUsername are required" });
    }

    const device = await dbService.registerDevice(patientId, deviceId, mqttUsername);
    res.status(201).json({ message: "Device registered", device });
  } catch (error) {
    console.error("Register Device Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getMyDevices = async (req, res) => {
  try {
    const patientId = req.user.id;
    const devices = await dbService.getDevicesForPatient(patientId);
    res.json({ devices });
  } catch (error) {
    console.error("Get Devices Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};



// ================= SESSIONS =================

exports.startSession = async (req, res) => {
  try {
    const { exerciseId } = req.body;
    let { deviceId } = req.body;
    const patientId = req.user.id;

    if (!deviceId) {
      const devices = await dbService.getDevicesForPatient(patientId);
      if (devices && devices.length > 0) {
        deviceId = devices[0].id;
      } else {
        // No deviceId in request and patient has no assigned device.
        // Fall back to the default prototype device. In a production
        // deployment with multiple exoskeletons, the client would be
        // required to specify deviceId explicitly.
        deviceId = 'dev_test_001';
        console.log(`[startSession] No deviceId specified for patient ${patientId}, using default 'dev_test_001'`);
      }
    }

    // Allow any patient to start a session with a shared device
    // (Previous ownership check was removed here per 'shared device' requirements)
    const device = await dbService.getDeviceById(deviceId);
    if (!device) {
      // It's okay if device doesn't exist in Devices table for test devices
      console.log(`[SessionController] Device ${deviceId} not found in Devices table, allowing anyway for shared use.`);
    }

    const sessionId = `sess_${uuidv4()}`;
    const startTime = new Date().toISOString();

    const sessionData = {
      deviceId,
      exerciseId: exerciseId || null,
      status: "active",
      startTime,
      endTime: null,
      waveformS3Key: null,
      sampleCount: null,
      durationSeconds: null,
      summary: {},
      events: []
    };

    // DB Record
    const session = await dbService.createSession(patientId, { id: sessionId, ...sessionData });

    // In-memory buffer
    sessionBuffer.startSession(sessionId, patientId, exerciseId, deviceId);

    // --- Added for Shared Device Routing ---
    const mqttService = require('../services/mqttService');
    if (typeof mqttService.invalidateDeviceCache === 'function') {
      mqttService.invalidateDeviceCache(deviceId);
    }
    // ---------------------------------------
    
    if (mqttService.client) {
      mqttService.client.publish(`flexio/${deviceId}/cmd`, JSON.stringify({ type: 'start' }));
      console.log(`[MQTT] Published start command to flexio/${deviceId}/cmd`);
    }

    res.status(201).json({ message: "Session started", sessionId, startTime });
  } catch (error) {
    console.error("Start Session Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.endSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const patientId = req.user.id;

    const dbRecord = await dbService.getSessionById(sessionId);
    if (!dbRecord) return res.status(404).json({ message: "Session not found" });

    // Authz check
    if (dbRecord.patientId !== patientId && req.user.role !== 'doctor') {
      return res.status(403).json({ message: "Not authorized" });
    }

    if (dbRecord.status !== 'active') {
      return res.status(400).json({ message: `Cannot end session with status ${dbRecord.status}` });
    }

    // Stop buffering and get data
    const buffer = sessionBuffer.endSession(sessionId);
    if (!buffer) {
      return res.status(400).json({ message: "Active session buffer not found. It may have been lost or never started." });
    }

    // --- Added for Warning Detection ---
    const warningDetector = require('../services/warningDetector');
    warningDetector.resetSession(sessionId);
    // -----------------------------------

    const endTimeDate = new Date();
    const durationSeconds = Math.round((endTimeDate.getTime() - new Date(dbRecord.startTime).getTime()) / 1000);

    let finalStatus = "completed";
    let s3KeyPrefix = null;

    try {
      // Flush to S3
      s3KeyPrefix = await waveformWriter.flushSessionToS3(sessionId, buffer);
    } catch (s3Err) {
      console.error(`[endSession] S3 flush failed for ${sessionId}:`, s3Err);
      finalStatus = "abort_flush_failed";
    }

    const { summary } = req.body;

    // Update DB
    const updates = {
      endTime: endTimeDate.toISOString(),
      status: finalStatus,
      sampleCount: buffer.sampleCount,
      durationSeconds,
      events: buffer.events // encrypted by dbService automatically
    };

    if (summary) {
      updates.summary = summary;
    }

    if (s3KeyPrefix) {
      updates.waveformS3Key = s3KeyPrefix;
    }

    const updatedSession = await dbService.updateSession(sessionId, updates);

    // Fire report generation trigger (fire-and-forget)
    triggerReportGeneration(sessionId, patientId, s3KeyPrefix)
      .catch(err => console.warn('[report] trigger failed:', err.message));

    // --- Added for Shared Device Routing ---
    const mqttService = require('../services/mqttService');
    if (typeof mqttService.invalidateDeviceCache === 'function') {
      mqttService.invalidateDeviceCache(dbRecord.deviceId);
    }
    // ---------------------------------------
    
    if (mqttService.client) {
      mqttService.client.publish(`flexio/${dbRecord.deviceId}/cmd`, JSON.stringify({ type: 'stop' }));
      console.log(`[MQTT] Published stop command to flexio/${dbRecord.deviceId}/cmd`);
    }

    res.json({ message: "Session ended", session: updatedSession });
  } catch (error) {
    console.error("End Session Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.abortSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const patientId = req.user.id;

    const dbRecord = await dbService.getSessionById(sessionId);
    if (!dbRecord || dbRecord.patientId !== patientId) {
      return res.status(404).json({ message: "Session not found or unauthorized" });
    }

    if (dbRecord.status !== 'active') {
      return res.status(400).json({ message: "Session is not active" });
    }

    sessionBuffer.abortSession(sessionId);

    const mqttService = require('../services/mqttService');
    if (mqttService.client) {
      mqttService.client.publish(`flexio/${dbRecord.deviceId}/cmd`, JSON.stringify({ type: 'stop' }));
      console.log(`[MQTT] Published stop command to flexio/${dbRecord.deviceId}/cmd`);
    }

    const updatedSession = await dbService.updateSession(sessionId, {
      status: "aborted",
      endTime: new Date().toISOString()
    });

    res.json({ message: "Session aborted", session: updatedSession });
  } catch (error) {
    console.error("Abort Session Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getPatientSessions = async (req, res) => {
  try {
    const { patientId } = req.params;

    // Authz
    if (req.user.id !== patientId && req.user.role !== 'doctor') {
      return res.status(403).json({ message: "Not authorized" });
    }

    const sessions = await dbService.getSessionsForPatient(patientId);
    // Only return completed/aborted for history typically, but let's return all.
    res.json({ sessions });
  } catch (error) {
    console.error("Get Sessions Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getSessionDetails = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = await dbService.getSessionById(sessionId);

    if (!session) return res.status(404).json({ message: "Session not found" });

    if (session.patientId !== req.user.id && req.user.role !== 'doctor') {
      return res.status(403).json({ message: "Not authorized" });
    }

    res.json({ session });
  } catch (error) {
    console.error("Get Session Details Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getSessionWaveformUrls = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = await dbService.getSessionById(sessionId);

    if (!session) return res.status(404).json({ message: "Session not found" });

    if (session.patientId !== req.user.id && req.user.role !== 'doctor') {
      return res.status(403).json({ message: "Not authorized" });
    }

    if (!session.waveformS3Key) {
      return res.status(404).json({ message: "No waveforms available for this session" });
    }

    const prefix = session.waveformS3Key;
    const bucket = getWaveformsBucket();

    // Generate signed URLs (valid for 1 hour)
    const emgUrl = await getSignedReadUrl(`${prefix}emg.csv`, 3600, bucket);
    const imuUrl = await getSignedReadUrl(`${prefix}imu.csv`, 3600, bucket);
    const eventsUrl = await getSignedReadUrl(`${prefix}events.json`, 3600, bucket);

    res.json({
      urls: {
        emg: emgUrl,
        imu: imuUrl,
        events: eventsUrl
      }
    });
  } catch (error) {
    console.error("Get Waveform URLs Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.simulateTelemetry = async (req, res) => {
  if (process.env.NODE_ENV === 'production') {
    return res.status(404).json({ message: "Not found" });
  }

  try {
    const { sessionId } = req.params;
    const patientId = req.user.id;
    const { kind, count = 50 } = req.body;

    const dbRecord = await dbService.getSessionById(sessionId);
    if (!dbRecord || dbRecord.patientId !== patientId) {
      return res.status(404).json({ message: "Session not found or unauthorized" });
    }

    if (dbRecord.status !== 'active') {
      return res.status(400).json({ message: "Session is not active" });
    }

    const deviceId = dbRecord.deviceId;

    for (let i = 0; i < count; i++) {
      let payload;
      const ts = Date.now() + (i * 1000); // spread them out roughly

      if (kind === 'emg') {
        payload = {
          ts,
          deviceId,
          sensors: [{ ch: 'emg1', samples: Array.from({ length: 50 }, () => Math.random() * 100) }]
        };
      } else if (kind === 'imu') {
        payload = {
          ts,
          deviceId,
          samples: Array.from({ length: 50 }, () => ({
            kneeAngle: Math.random() * 90,
            thighGravity: [Math.random(), Math.random(), Math.random()],
            shinGravity: [Math.random(), Math.random(), Math.random()]
          }))
        };
      } else if (kind === 'event') {
        payload = {
          ts,
          deviceId,
          event: 'synthetic_event',
          detail: 'Simulated event'
        };
      } else {
        return res.status(400).json({ message: "Invalid kind. Must be emg, imu, or event" });
      }

      sessionBuffer.simulate(sessionId, kind, payload);
    }

    res.json({ message: `Successfully injected ${count} ${kind} readings into session ${sessionId}` });
  } catch (error) {
    console.error("Simulate Telemetry Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
// ================= HARDWARE COMMANDS & CALIBRATION =================

exports.calibrateSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const dbRecord = await dbService.getSessionById(sessionId);
    if (!dbRecord) return res.status(404).json({ message: "Session not found" });

    // Ensure session is active
    if (dbRecord.status !== 'active') {
      return res.status(400).json({ message: "Session is not active" });
    }

    const sensorFusion = require('../services/sensorFusion');
    const offset = sensorFusion.calibrate(sessionId);

    res.json({ message: "Calibration successful", offset });
  } catch (error) {
    console.error("Calibrate Session Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.commandSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { type, payload } = req.body; // e.g. type: 'stop' | 'set_angle'
    const dbRecord = await dbService.getSessionById(sessionId);
    if (!dbRecord) return res.status(404).json({ message: "Session not found" });

    // Ensure session is active
    if (dbRecord.status !== 'active') {
      return res.status(400).json({ message: "Session is not active" });
    }

    const deviceId = dbRecord.deviceId;
    console.log(`[STUB] No ESP listening on cmd topic yet. Publishing command to flexio/${deviceId}/cmd`, type, payload);

    const mqttService = require('../services/mqttService');
    if (mqttService.client) {
      mqttService.client.publish(`flexio/${deviceId}/cmd`, JSON.stringify({ type, ...payload }));
    }

    res.json({ message: "Command dispatched" });
  } catch (error) {
    console.error("Command Session Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ================= AI REPORT WEBHOOK =================

exports.receiveAiReport = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const providedToken = req.headers['x-service-token'];

    // We pull the secret token from the .env file
    const expectedToken = process.env.AI_SERVICE_TOKEN;

    // 1. Security Check: Ensure it came from your Python AI Service
    if (providedToken !== expectedToken) {
      console.warn(`⚠️ [Webhook] Unauthorized AI callback attempt for session: ${sessionId}`);
      return res.status(401).json({ message: "Unauthorized AI service." });
    }

    // 2. Handle AI Errors (e.g., Python crashed, S3 download failed)
    if (req.body.error) {
      console.error(`❌ [Webhook] AI Service failed for session ${sessionId}:`, req.body.error);

      // Update DynamoDB to show the doctor a "Failed" status
      await dbService.updateSession(sessionId, {
        reportStatus: 'failed',
        reportError: req.body.error
      });
      return res.status(200).json({ message: "Error logged successfully." });
    }

    // 3. Handle Success
    const aiReport = req.body.report;
    console.log(`✅ [Webhook] Received completed AI Report for session: ${sessionId}`);

    // 4. Save to DynamoDB
    // Notice in your endSession you have "events: buffer.events // encrypted by dbService automatically".
    // We pass the report into dbService here so your v1 AES helper can encrypt the medical text too!
    await dbService.updateSession(sessionId, {
      reportStatus: 'completed',
      report: aiReport
    });

    // 5. Respond 200 OK so the Python service knows we caught the plate
    return res.status(200).json({ message: "Report successfully saved to database." });

  } catch (error) {
    console.error("Receive AI Report Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getActiveSessionForPatient = async (req, res) => {
  try {
    const requestingUserId = req.user.id;
    const requestingRole   = req.user.role;
    const { patientId } = req.params;

    // Auth: a patient can only see their own; a doctor can see any of their patients
    if (requestingRole === 'patient' && requestingUserId !== patientId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const sessions = await dbService.findActiveSessionsByPatient(patientId);
    if (!sessions.length) {
      return res.status(404).json({
        active: false,
        message: 'No active session for this patient.',
      });
    }
    const latest = sessions.reduce(
      (a, b) => (a.startTime > b.startTime ? a : b)
    );
    return res.json({
      active: true,
      sessionId: latest.id || latest.sessionId,
      deviceId:  latest.deviceId,
      startTime: latest.startTime,
    });
  } catch (err) {
    console.error('[getActiveSessionForPatient]', err);
    return res.status(500).json({ error: err.message });
  }
};