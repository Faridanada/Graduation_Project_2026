const dbService = require('./dbService');
const { applyReportToSession } = require('../controllers/reportController');

/**
 * Simulates an LLM generating a session report
 */
async function generateFakeReport(sessionId, patientId, waveformS3Key) {
  try {
    // Simulate 5-10 seconds latency
    const delay = Math.floor(Math.random() * 5000) + 5000;
    await new Promise(resolve => setTimeout(resolve, delay));

    const session = await dbService.getSessionById(sessionId);
    if (!session) {
      throw new Error("Session not found during fake report generation");
    }

    const durationSeconds = session.durationSeconds || 1800;
    const durationMin = Math.round(durationSeconds / 60);
    const repetitionsCompleted = Math.floor(Math.random() * 15) + 18; // 18-32

    const peak1 = (Math.random() * 0.35 + 0.6).toFixed(2); // 0.6 - 0.95
    const peak2 = (Math.random() * 0.35 + 0.6).toFixed(2);
    const rms1 = (Math.random() * 0.3 + 0.3).toFixed(2); // 0.3 - 0.6
    const rms2 = (Math.random() * 0.3 + 0.3).toFixed(2);

    const minPeak = Math.min(parseFloat(peak1), parseFloat(peak2));
    const maxPeak = Math.max(parseFloat(peak1), parseFloat(peak2));
    const symScore = maxPeak > 0 ? (minPeak / maxPeak).toFixed(2) : 1;
    let symInterpretation = "balanced";
    if (symScore < 0.7) symInterpretation = "significant imbalance";
    else if (symScore < 0.85) symInterpretation = "mild imbalance";

    const fatigue1 = parseFloat((Math.random() * 0.5 + 0.1).toFixed(2)); // 0.1 - 0.6
    const fatigue2 = parseFloat((Math.random() * 0.5 + 0.1).toFixed(2));
    const maxFatigue = Math.max(fatigue1, fatigue2);
    let fatInterpretation = "high";
    if (maxFatigue < 0.3) fatInterpretation = "low";
    else if (maxFatigue < 0.5) fatInterpretation = "moderate";

    const report = {
      generatedAt: new Date().toISOString(),
      model: "fake-generator-v1",
      summary: `Patient completed a ${durationMin}-minute session with ${repetitionsCompleted} repetitions. Range of motion was within expected limits with ${fatInterpretation} fatigue indicators detected toward the end. Muscle symmetry appeared ${symInterpretation}.`,
      metrics: {
        duration: { value: durationSeconds, unit: "seconds" },
        rangeOfMotion: {
          imu1: { min: 10 + Math.random()*10, max: 75 + Math.random()*20, average: 50 + Math.random()*15 },
          imu2: { min: 10 + Math.random()*10, max: 75 + Math.random()*20, average: 50 + Math.random()*15 },
          unit: "degrees"
        },
        peakEmg: {
          emg1: { peak: parseFloat(peak1), rms: parseFloat(rms1) },
          emg2: { peak: parseFloat(peak2), rms: parseFloat(rms2) },
          unit: "normalized"
        },
        muscleSymmetry: { score: parseFloat(symScore), interpretation: symInterpretation },
        fatigueIndex: {
          emg1: fatigue1,
          emg2: fatigue2,
          interpretation: fatInterpretation
        },
        repetitionsCompleted
      },
      observations: [
        "Patient showed steady engagement throughout the session.",
        `Average range of motion maintained around 55 degrees.`
      ],
      concerns: [],
      recommendations: [
        "Continue current plan without major adjustments.",
        "Ensure patient rests adequately before next session."
      ],
      safetyEvents: []
    };

    // Add random concern sometimes
    if (Math.random() < 0.2) {
      report.concerns.push({
        severity: Math.random() < 0.1 ? "medium" : "low",
        type: "Fatigue",
        description: "Patient exhibited minor form degradation near the end of the session."
      });
    }

    // Translate keyword events into safety events if any exist
    if (session.events && Array.isArray(session.events)) {
      report.safetyEvents = session.events
        .filter(e => e.type === 'verbal_keyword')
        .map(e => ({
          type: "verbal_stop",
          timestamp: e.timestamp,
          atSecond: e.sessionTime,
          context: `Patient uttered keyword: ${e.keyword}`
        }));
    }

    // Internal save
    await applyReportToSession(sessionId, { report });
    console.log(`[fakeReportGenerator] Completed report for session ${sessionId}`);
  } catch (error) {
    console.error("[fakeReportGenerator Error]:", error);
    await applyReportToSession(sessionId, { error: error.message || "Failed to generate fake report" });
  }
}

exports.generateFakeReport = generateFakeReport;
