const dbService = require('../services/dbService');
const crypto = require('crypto');

/**
 * Report Data Structure (The Contract)
 *
 * @typedef {Object} SessionReport
 * @property {string} generatedAt - ISO timestamp of generation
 * @property {string} model - e.g., "fake-generator-v1" or "claude-sonnet-4-7"
 * @property {string} summary - 1-2 paragraph natural language overview
 * @property {Object} metrics - Key session metrics
 * @property {Object} metrics.duration - { value: number, unit: "seconds" }
 * @property {Object} metrics.rangeOfMotion - e.g., { imu1: {min, max, average}, imu2: {min, max, average}, unit: "degrees" }
 * @property {Object} metrics.peakEmg - e.g., { emg1: {peak, rms}, emg2: {peak, rms}, unit: "normalized" }
 * @property {Object} metrics.muscleSymmetry - { score: number, interpretation: string }
 * @property {Object} metrics.fatigueIndex - { emg1: number, emg2: number, interpretation: string }
 * @property {number} metrics.repetitionsCompleted - Total repetitions
 * @property {string[]} observations - Array of observational sentences
 * @property {Object[]} concerns - { severity: "low"|"medium"|"high", type: string, description: string }
 * @property {string[]} recommendations - Array of recommendation sentences
 * @property {Object[]} safetyEvents - { type: string, timestamp: string, atSecond: number, context: string }
 */

/**
 * Shared helper to apply a generated report or error to a session
 */
async function applyReportToSession(sessionId, { report, error }) {
  if (error) {
    await dbService.updateSession(sessionId, {
      reportStatus: 'failed',
      reportError: error
    });
    return;
  }

  // Validate basic top-level fields to be forgiving but safe
  if (!report || !report.summary || !report.metrics) {
    throw new Error('Invalid report structure: missing summary or metrics');
  }

  await dbService.updateSession(sessionId, {
    reportStatus: 'completed',
    report: report, // Interceptor will encrypt this
    reportGeneratedAt: new Date().toISOString()
  });
}
exports.applyReportToSession = applyReportToSession;

/**
 * GET /api/sessions/:sessionId/report
 * Fetch a session report
 */
exports.getReport = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = await dbService.getSessionById(sessionId);

    if (!session) {
      return res.status(404).json({ message: "Session not found" });
    }

    // Authz: Patient who owns the session, OR Doctor assigned to the patient
    if (session.patientId !== req.user.id) {
      if (req.user.role !== 'doctor') {
        return res.status(403).json({ message: "Not authorized" });
      } else {
        const patient = await dbService.getUserById(session.patientId);
        if (!patient || patient.assignedDoctorId !== req.user.id) {
          return res.status(403).json({ message: "Not authorized for this patient's records" });
        }
      }
    }

    res.json({
      reportStatus: session.reportStatus || 'pending',
      report: session.report || null,
      reportGeneratedAt: session.reportGeneratedAt || null,
      reportError: session.reportError || null
    });
  } catch (error) {
    console.error("[getReport Error]:", error);
    res.status(500).json({ message: "Server error" });
  }
};

/**
 * POST /api/sessions/:sessionId/regenerate-report
 * Trigger regeneration of the report
 */
exports.regenerateReport = async (req, res) => {
  try {
    const { sessionId } = req.params;

    if (req.user.role !== 'doctor') {
      return res.status(403).json({ message: "Only doctors can regenerate reports" });
    }

    const session = await dbService.getSessionById(sessionId);
    if (!session) {
      return res.status(404).json({ message: "Session not found" });
    }

    // Authz: Doctor assigned to patient
    const patient = await dbService.getUserById(session.patientId);
    if (!patient || patient.assignedDoctorId !== req.user.id) {
      return res.status(403).json({ message: "Not authorized for this patient's records" });
    }

    // Clear old data and set to processing
    await dbService.updateSession(sessionId, {
      reportStatus: 'processing',
      reportError: null,
      report: null,
      reportGeneratedAt: null
    });

    // Fire the trigger (fire-and-forget)
    const { triggerReportGeneration } = require('../services/reportTrigger');
    triggerReportGeneration(sessionId, session.patientId, session.waveformS3Key)
      .catch(err => console.warn('[report] trigger failed:', err.message));

    res.json({ reportStatus: "processing", message: "Report generation triggered" });
  } catch (error) {
    console.error("[regenerateReport Error]:", error);
    res.status(500).json({ message: "Server error" });
  }
};

/**
 * PATCH /api/sessions/:sessionId/report
 * Receive report from AI Service
 */
exports.patchReport = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const providedToken = req.headers['x-service-token'];
    
    const a = Buffer.from(providedToken || '', 'utf8');
    const b = Buffer.from(process.env.AI_SERVICE_TOKEN || '', 'utf8');
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
      return res.status(401).json({ message: "Unauthorized service token" });
    }

    const { report, error } = req.body;
    
    if (!report && !error) {
      return res.status(400).json({ message: "Body must include report or error" });
    }

    await applyReportToSession(sessionId, { report, error });

    res.json({ ok: true });
  } catch (error) {
    console.error("[patchReport Error]:", error);
    res.status(500).json({ message: "Server error" });
  }
};
